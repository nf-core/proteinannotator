/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { FAA_SEQFU_SEQKIT       } from '../subworkflows/nf-core/faa_seqfu_seqkit/main'
include { DOMAIN_ANNOTATION      } from '../subworkflows/local/domain_annotation'
include { FUNCTIONAL_ANNOTATION  } from '../subworkflows/local/functional_annotation'
include { S4PRED_RUNMODEL        } from '../modules/nf-core/s4pred/runmodel/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_proteinannotator_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PROTEINANNOTATOR {
    take:
    ch_samplesheet // channel: samplesheet read in from --input
    multiqc_config
    multiqc_logo
    multiqc_methods_description
    outdir
    skip_preprocessing      // boolean
    skip_pfam               // boolean
    pfam_db                 // string, path to the pfam HMM database, if already exists
    pfam_latest_link        // string, path to the latest pfam HMM database, to download
    skip_funfam             // boolean
    funfam_db               // string, path to the pfam HMM database, if already exists
    funfam_latest_link      // string, path to the latest pfam HMM database, to download
    skip_nmpfams            // boolean
    nmpfams_db              // string
    nmpfams_latest_link     // string
    skip_metagroot          // boolean
    metagroot_db            // string, path to the metagroot HMM database, if already exists
    metagroot_latest_link   // string, path to the latest metagroot HMM database, to download
    skip_interproscan       // boolean
    interproscan_db_url     // string, url to download db
    interproscan_db         // string, existing db
    skip_s4pred             // boolean

    main:
    def ch_versions = channel.empty()
    def ch_multiqc_files = channel.empty()

    FAA_SEQFU_SEQKIT( ch_samplesheet, skip_preprocessing )

    DOMAIN_ANNOTATION (
        FAA_SEQFU_SEQKIT.out.fasta,
        skip_pfam,
        pfam_db,
        pfam_latest_link,
        skip_funfam,
        funfam_db,
        funfam_latest_link,
        skip_nmpfams,
        nmpfams_db,
        nmpfams_latest_link,
        skip_metagroot,
        metagroot_db,
        metagroot_latest_link
    )
    ch_versions = ch_versions.mix( DOMAIN_ANNOTATION.out.versions )

    FUNCTIONAL_ANNOTATION (
        FAA_SEQFU_SEQKIT.out.fasta,
        skip_interproscan,
        interproscan_db_url,
        interproscan_db
    )

    if (!skip_s4pred) {
        S4PRED_RUNMODEL( FAA_SEQFU_SEQKIT.out.fasta )
        ch_versions = ch_versions.mix( S4PRED_RUNMODEL.out.versions.first() )
    }

    //
    // Collate and save software versions
    //
    def topic_versions = channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    def ch_collated_versions = softwareVersionsToYAML(ch_versions.mix(topic_versions.versions_file))
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${outdir}/pipeline_info",
            name: 'nf_core_'  +  'proteinannotator_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        )

    //
    // MODULE: MultiQC
    //
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    def ch_summary_params = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")
    def ch_workflow_summary = channel.value(paramsSummaryMultiqc(ch_summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    def ch_multiqc_custom_methods_description = multiqc_methods_description
        ? file(multiqc_methods_description, checkIfExists: true)
        : file("${projectDir}/assets/methods_description_template.yml", checkIfExists: true)
    def ch_methods_description = channel.value(methodsDescriptionText(ch_multiqc_custom_methods_description))
    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml', sort: true))
    ch_multiqc_files = ch_multiqc_files.mix(FAA_SEQFU_SEQKIT.out.multiqc_files.collect{ f -> f[1] }.ifEmpty([]))
    MULTIQC(
        ch_multiqc_files.flatten().collect().map { files ->
            [
                [id: 'proteinannotator'],
                files,
                multiqc_config
                    ? file(multiqc_config, checkIfExists: true)
                    : file("${projectDir}/assets/multiqc_config.yml", checkIfExists: true),
                multiqc_logo ? file(multiqc_logo, checkIfExists: true) : [],
                [],
                [],
            ]
        }
    )
    emit:multiqc_report = MULTIQC.out.report.map { _meta, report -> [report] }.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]
}
