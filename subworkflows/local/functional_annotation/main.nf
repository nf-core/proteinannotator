// include { INTERPROSCAN_DATABASE } from '../../modules/local/interproscan/database/main'
include { INTERPROSCAN } from '../../../modules/nf-core/interproscan/main'

workflow FUNCTIONAL_ANNOTATION {
    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]

    main:

    ch_versions = channel.empty()

    // TODO UPDATE according to funcscan below

    // if (params.interproscan_db != null) {
    //     ch_interproscan_db = channel.fromPath(params.interproscan_db)
    //         .first()
    // }
    // else {
    //     INTERPROSCAN_DATABASE(params.interproscan_db_url)
    //     ch_versions = ch_versions.mix(INTERPROSCAN_DATABASE.out.versions)
    //     ch_interproscan_db = INTERPROSCAN_DATABASE.out.db
    // }

    INTERPROSCAN( ch_fasta, [] ) // TESTING

    // // Create a multifasta, with one fasta per entry, add the sequence ID to the meta id
    // ch_fasta
    //     .map { meta, fasta ->
    //         [
    //             [id: "${meta.id}_${fasta.splitFasta(record: [id: true]).id[0].replaceAll(/\|/, '-')}"],
    //             fasta.splitFasta(file: true),
    //         ]
    //     }
    //     .transpose()
    //     .set { ch_multifasta }

    // //
    // // SUBWORKFLOW: Run InterProScan
    // //

    // if (!params.skip_interproscan) {
    //     INTERPROSCAN(
    //         ch_multifasta
    //     )
    //     ch_versions = ch_versions.mix(INTERPROSCAN.out.versions.first())
    // }

    emit:
    versions = ch_versions // channel: [ versions.yml ]
}
