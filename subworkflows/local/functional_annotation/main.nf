<<<<<<< HEAD
// Import Diamond Subworkflow
include { DIAMOND } from '../diamond/main'
// Import Annotator Subworfklows
include { INTERPROSCAN } from '../interproscan/main'

=======
include { ARIA2        } from '../../../modules/nf-core/aria2/main'
include { UNTAR        } from '../../../modules/nf-core/untar/main'
include { INTERPROSCAN } from '../../../modules/nf-core/interproscan/main'
>>>>>>> dev

workflow FUNCTIONAL_ANNOTATION {
    take:
    ch_fasta            // channel: [ val(meta), [ fasta ] ]
    skip_interproscan   // boolean
    interproscan_db_url // string, url to download db
    interproscan_db     // string, existing db

    main:
    ch_interproscan_tsv = channel.empty()
    ch_versions         = channel.empty()

<<<<<<< HEAD
    ch_versions = Channel.empty()

    //
    // SUBWORKFLOW: Run Diamond
    //

    DIAMOND(
        ch_fasta
    )
    ch_diamond_tsv = DIAMOND.out.tsv
    ch_versions = ch_versions.mix(DIAMOND.out.versions.first())
=======
    if (!skip_interproscan) {
        if (interproscan_db) {
            ch_interproscan_db = channel.fromPath(interproscan_db).first()
        }
        else {
            ARIA2( [ [ id:'interproscan_db' ], interproscan_db_url ] )
            ch_versions = ch_versions.mix(ARIA2.out.versions.first())
>>>>>>> dev

            UNTAR( ARIA2.out.downloaded_file )
            ch_interproscan_db = UNTAR.out.untar.map{ f -> f[1] }
        }

<<<<<<< HEAD
    if (!params.skip_interproscan) {
        // Create a multifasta, with one fasta per entry, add the sequence ID to the meta id
        ch_fasta
            .map { meta, fasta ->
                [
                    [id: "${meta.id}_${fasta.splitFasta(record: [id: true]).id[0].replaceAll(/\|/, '-')}"],
                    fasta.splitFasta(file: true),
                ]
            }
            .transpose()
            .set { ch_multifasta }

        INTERPROSCAN(
            ch_multifasta
        )
        ch_versions = ch_versions.mix(INTERPROSCAN.out.versions.first())
    }

    emit:
    diamond_tsv = ch_diamond_tsv    // channel: [ val(meta), path(tsv) ]
    versions = ch_versions          // channel: [ versions.yml ]
=======
        INTERPROSCAN( ch_fasta, ch_interproscan_db )
        ch_interproscan_tsv = ch_interproscan_tsv.mix(INTERPROSCAN.out.tsv)
    }

    emit:
    interproscan_tsv = ch_interproscan_tsv
    versions         = ch_versions         // channel: [ versions.yml ]
>>>>>>> dev
}
