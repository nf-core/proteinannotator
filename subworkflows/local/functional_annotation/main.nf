// Import Diamond Subworkflow
include { DIAMOND } from '../diamond/main'

include { ARIA2        } from '../../../modules/nf-core/aria2/main'
include { UNTAR        } from '../../../modules/nf-core/untar/main'
include { INTERPROSCAN } from '../../../modules/nf-core/interproscan/main'

workflow FUNCTIONAL_ANNOTATION {
    take:
    ch_fasta            // channel: [ val(meta), [ fasta ] ]
    skip_interproscan   // boolean
    interproscan_db_url // string, url to download db
    interproscan_db     // string, existing db

    main:
    ch_interproscan_tsv = channel.empty()
    ch_versions         = channel.empty()

    //
    // SUBWORKFLOW: Run Diamond
    //

    DIAMOND(
        ch_fasta
    )
    ch_diamond_tsv = DIAMOND.out.tsv
    ch_versions = ch_versions.mix(DIAMOND.out.versions.first())

    //
    // SUBWORKFLOW: Run Interproscan
    //
    if (!skip_interproscan) {
        if (interproscan_db) {
            ch_interproscan_db = channel.fromPath(interproscan_db).first()
        }
        else {
            ARIA2( [ [ id:'interproscan_db' ], interproscan_db_url ] )
            ch_versions = ch_versions.mix(ARIA2.out.versions.first())

            UNTAR( ARIA2.out.downloaded_file )
            ch_interproscan_db = UNTAR.out.untar.map{ f -> f[1] }
        }

        INTERPROSCAN( ch_fasta, ch_interproscan_db )
        ch_interproscan_tsv = ch_interproscan_tsv.mix(INTERPROSCAN.out.tsv)
    }

    emit:
    diamond_tsv      = ch_diamond_tsv
    interproscan_tsv = ch_interproscan_tsv
    versions         = ch_versions         // channel: [ versions.yml ]
}
