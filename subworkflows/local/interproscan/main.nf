// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { INTERPROSCAN_RUN     } from '../../../modules/local/interproscan/run/main'
include { UNTAR                } from '../../../modules/nf-core/untar/main'

workflow INTERPROSCAN {

    take:
    // TODO nf-core: edit input (take) channels
    ch_multifasta // channel: [ val(meta), fasta ]

    main:

    ch_versions = Channel.empty()

    println("params.interproscan_database: ${params.interproscan_database}")
    println("params.interproscan_tar_gz: ${params.interproscan_tar_gz}")
    println("params.interproscan_database_version: ${params.interproscan_database_version}")

    if (!params.interproscan_database_version) {
        error("--interproscan_database_version must be provided! Exiting.")
    }

    if (params.interproscan_tar_gz){
        println("params.interproscan_tar_gz exists, untarring")
        interproscan_compressed = [
            [id: params.interproscan_database_version],
            file(params.interproscan_tar_gz, checkIfExists: true)
        ]
        println("interproscan_compressed: ${interproscan_compressed}")
        UNTAR(interproscan_compressed)
        interproscan_db = UNTAR.out.untar
            // Get only the "data" subfolder for proper mounting in the InterProScan
            .map{ meta, folder -> tuple( folder.resolve('data'), params.interproscan_database_version) }
    } else if (params.interproscan_database ) {
        interproscan_db = [file(params.interproscan_database, checkIfExists: true), params.interproscan_database_version]
    } else {
        error("No interproscan database provided with either --interproscan_database or --interproscan_tar_gz! Exiting.")
    }

    INTERPROSCAN_RUN (
        ch_multifasta,
        interproscan_db
    )
    ch_versions = ch_versions.mix(INTERPROSCAN_RUN.out.versions.first())

    emit:
    // // TODO nf-core: edit emitted channels
    tsv      = INTERPROSCAN_RUN.out.tsv          // channel: [ val(meta), [ tsv ] ]
    xml      = INTERPROSCAN_RUN.out.xml          // channel: [ val(meta), [ xml ] ]
    gff3     = INTERPROSCAN_RUN.out.gff3         // channel: [ val(meta), [ gff3 ] ]
    json     = INTERPROSCAN_RUN.out.json         // channel: [ val(meta), [ json ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

