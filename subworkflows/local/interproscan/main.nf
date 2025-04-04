// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { INTERPROSCAN_SETUP   } from '../../../modules/local/interproscan/setup/main'
include { INTERPROSCAN_RUN     } from '../../../modules/local/interproscan/run/main'

workflow INTERPROSCAN {

    take:
    // TODO nf-core: edit input (take) channels
    ch_multifasta // channel: [ val(meta), fasta ]
    interproscan_database // channel [ file(interproscan_database), val(interproscan_version) ]

    main:

    ch_versions = Channel.empty()

    if (!params.skip_interproscan_database_setup) {
        INTERPROSCAN_SETUP (
            [file(params.interproscan_database, checkIfExists: true), params.interproscan_database_version]
        )
        ch_versions = ch_versions.mix(INTERPROSCAN_SETUP.out.versions.first())
        interproscan_db = INTERPROSCAN_SETUP.out.interproscan_db
    } else {
        interproscan_db = [file(params.interproscan_database, checkIfExists: true), params.interproscan_database_version]
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

