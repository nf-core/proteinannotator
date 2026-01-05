// Import modules
include { EGGNOGMAPPER } from '../../../modules/nf-core/eggnogmapper/main'
include { EGGNOG_DOWNLOAD_DB } from '../../../modules/local/eggnog_download_db/main'


workflow EGGNOG {
    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]

    main:

    ch_versions = Channel.empty()
    ch_eggnog_annotations = Channel.empty()
    ch_eggnog_orthologs = Channel.empty()
    ch_eggnog_hits = Channel.empty()

    if (!params.skip_eggnog) {
        // Download databases if not provided
        if (!params.eggnog_data_dir) {
            EGGNOG_DOWNLOAD_DB(true)
            ch_eggnog_data_dir = EGGNOG_DOWNLOAD_DB.out.data_dir
            ch_eggnog_db = EGGNOG_DOWNLOAD_DB.out.db
            ch_eggnog_diamond_db = EGGNOG_DOWNLOAD_DB.out.diamond_db.map { dmnd -> [[id: 'eggnog_diamond'], dmnd] }
            ch_versions = ch_versions.mix(EGGNOG_DOWNLOAD_DB.out.versions)
        } else {
            // Use provided database paths
            ch_eggnog_data_dir = Channel.fromPath(params.eggnog_data_dir, checkIfExists: true)
            ch_eggnog_db = params.eggnog_db ? Channel.fromPath(params.eggnog_db, checkIfExists: true) : Channel.empty()
            ch_eggnog_diamond_db = params.eggnog_diamond_db ?
                Channel.fromPath(params.eggnog_diamond_db, checkIfExists: true).map { dmnd -> [[id: 'eggnog_diamond'], dmnd] } :
                Channel.value([[id: 'eggnog_diamond'], []])
        }

        EGGNOGMAPPER(
            ch_fasta,
            ch_eggnog_db.ifEmpty([]),
            ch_eggnog_data_dir,
            ch_eggnog_diamond_db
        )
        ch_eggnog_annotations = EGGNOGMAPPER.out.annotations
        ch_eggnog_orthologs = EGGNOGMAPPER.out.orthologs
        ch_eggnog_hits = EGGNOGMAPPER.out.hits
        ch_versions = ch_versions.mix(EGGNOGMAPPER.out.versions.first())
    }

    emit:
    annotations = ch_eggnog_annotations // channel: [ val(meta), path(*.emapper.annotations) ]
    orthologs   = ch_eggnog_orthologs   // channel: [ val(meta), path(*.emapper.seed_orthologs) ]
    hits        = ch_eggnog_hits        // channel: [ val(meta), path(*.emapper.hits) ]
    versions    = ch_versions           // channel: [ versions.yml ]
}
