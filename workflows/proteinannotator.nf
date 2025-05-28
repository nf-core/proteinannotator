/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { SEQKIT_STATS           } from '../modules/nf-core/seqkit/stats/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_proteinannotator_pipeline'
include { FUNCTIONAL_ANNOTATION  } from '../subworkflows/local/functional_annotation'
include { MMSEQS_SEARCH          } from '../modules/nf-core/mmseqs/search/main'
include { MTMALIGN_ALIGN         } from '../modules/nf-core/mtmalign/align/main'
include { UNIFIRE                } from '../subworkflows/local/unifire/main'
include { UNTAR                  } from '../modules/nf-core/untar/main'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow PROTEINANNOTATOR {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // Unifire channels
    // ch_taxadb = params.ete4_taxadb ? Channel.fromPath(params.ete4_taxadb, checkIfExists: true) : Channel.empty()

    // if the params.pirsr_data ends in .tar.gz, then it needs to be unpacked with UNTAR
    // else, we will assume it is a direcory and set it to the channel directly
    // ch_pirsr_data = !params.unifire_pirsr_data ? Channel.empty() :
    //     params.unifire_pirsr_data.endsWith('.tar.gz')
    //         ? UNTAR(Channel.of([[:], file(params.unifire_pirsr_data)])).out.untar.map{out -> out[1]}
    //         : Channel.fromPath(params.unifire_pirsr_data, checkIfExists: true)

    // // Collect versions if UNTAR is used
    // if (params.unifire_pirsr_data && params.unifire_pirsr_data.endsWith('.tar.gz')) {
    //     ch_versions = ch_versions.mix(UNTAR.out.versions.first())
    // }

    // ch_pirsr_data = params.unifire_pirsr_data ? Channel.fromPath(params.unifire_pirsr_data, checkIfExists: true) : Channel.empty()
    // ch_unirule_rules = params.unifire_urml_unirule ? Channel.fromPath(params.unifire_urml_unirule, checkIfExists: true) : Channel.empty()
    // ch_arba_rules = params.unifire_urml_arba ? Channel.fromPath(params.unifire_urml_arba, checkIfExists: true) : Channel.empty()
    // ch_pirsr_rules = params.unifire_urml_pirsr ? Channel.fromPath(params.unifire_urml_pirsr, checkIfExists: true) : Channel.empty()
    // ch_unirule_template = params.unifire_urml_templates ? Channel.fromPath(params.unifire_urml_templates, checkIfExists: true) : Channel.empty()

    ch_samplesheet.view()

    FUNCTIONAL_ANNOTATION (
        ch_samplesheet
    )

    //
    // SUBWORKFLOW: Unifire
    //
    // TODO: it looks like the intention is to put this under FUNCTIONAL_ANNOTATION,
    // but the unifire subworkflow is already fully documented. Placing it under the
    // FUNCTIONAL_ANNOTATION subworkflow would require that 9 input channels get
    // redundantly documented in the functional annotation meta (they are already)
    // documented in the unifire modules, subworkflow, and the proteinannotator
    // schema. I would suggest it be placed in the main workflow as a result.
    // if (!params.skip_tools.contains('unifire')) {
    //         UNIFIRE_PREDICT(
    //             INTERPROSCAN.out.xml,
    //                 ch_taxadb,
    //                 ch_pirsr_data,
    //                 ch_unirule_rules,
    //                 ch_arba_rules,
    //                 ch_pirsr_rules,
    //                 ch_unirule_template,
    //                 [],
    //                 []
    //         )
    //         ch_versions = ch_versions.mix(UNIFIRE_PREDICT.out.versions.first())
    // }

    // todo: move this to stats on input fasta subworkflow
    SEQKIT_STATS(ch_samplesheet)
    ch_versions = ch_versions.mix(SEQKIT_STATS.out.versions)

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'proteinannotator_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }

    //
    // MODULE: MultiQC
    //
    ch_multiqc_config        = Channel.fromPath(
        "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    ch_multiqc_custom_config = params.multiqc_config ?
        Channel.fromPath(params.multiqc_config, checkIfExists: true) :
        Channel.empty()
    ch_multiqc_logo          = params.multiqc_logo ?
        Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
        Channel.empty()

    summary_params      = paramsSummaryMap(
        workflow, parameters_schema: "nextflow_schema.json")
    ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
        file(params.multiqc_methods_description, checkIfExists: true) :
        file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    ch_methods_description                = Channel.value(
        methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    ch_multiqc_files = ch_multiqc_files.mix(
        ch_methods_description.collectFile(
            name: 'methods_description_mqc.yaml',
            sort: true
        )
    )

    MULTIQC (
        ch_multiqc_files.collect(),
        ch_multiqc_config.toList(),
        ch_multiqc_custom_config.toList(),
        ch_multiqc_logo.toList(),
        [],
        []
    )

    emit:multiqc_report = MULTIQC.out.report.toList() // channel: /path/to/multiqc_report.html
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
