include { INTERPROSCAN_DATABASE } from '../../../modules/local/interproscan/database/main'
include { INTERPROSCAN          } from '../../../modules/nf-core/interproscan/main'

workflow FUNCTIONAL_ANNOTATION {
    take:
    ch_fasta                   // channel: [ val(meta), [ fasta ] ]
    skip_interproscan          // boolean
    interproscan_db_url        // string, url to download db
    interproscan_db            // string, existing db

    main:
    ch_interproscan_tsv = channel.empty()
    ch_versions         = channel.empty()

    if (!skip_interproscan) {
        if (interproscan_db != null) {
            ch_interproscan_db = channel.fromPath(interproscan_db).first()
        }
        else {
            INTERPROSCAN_DATABASE( interproscan_db_url )
            ch_versions        = ch_versions.mix(INTERPROSCAN_DATABASE.out.versions)
            ch_interproscan_db = INTERPROSCAN_DATABASE.out.db
        }

        INTERPROSCAN( ch_fasta, ch_interproscan_db )
        ch_interproscan_tsv = ch_interproscan_tsv.mix(INTERPROSCAN.out.tsv)
    }

    emit:
    interproscan_tsv = ch_interproscan_tsv
    versions         = ch_versions         // channel: [ versions.yml ]
}
