// Import Annotator Subworfklows
include { INTERPROSCAN } from '../interproscan/main'
include { EGGNOGMAPPER } from '../../../modules/nf-core/eggnogmapper/main'


workflow FUNCTIONAL_ANNOTATION {
    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow

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

    //
    // SUBWORKFLOW: Run InterProScan
    //

    if (!params.skip_interproscan) {
        INTERPROSCAN(
            ch_multifasta
        )
        ch_versions = ch_versions.mix(INTERPROSCAN.out.versions.first())
    }

    //
    // MODULE: Run eggNOG-mapper
    //

    ch_eggnog_annotations = Channel.empty()
    ch_eggnog_orthologs = Channel.empty()
    ch_eggnog_hits = Channel.empty()

    if (!params.skip_eggnog) {
        EGGNOGMAPPER(
            ch_multifasta,
            params.eggnog_db ?: [],
            params.eggnog_data_dir,
            params.eggnog_diamond_db ? [[id: 'eggnog_diamond'], params.eggnog_diamond_db] : [[id: 'eggnog_diamond'], []]
        )
        ch_eggnog_annotations = EGGNOGMAPPER.out.annotations
        ch_eggnog_orthologs = EGGNOGMAPPER.out.orthologs
        ch_eggnog_hits = EGGNOGMAPPER.out.hits
        ch_versions = ch_versions.mix(EGGNOGMAPPER.out.versions.first())
    }

    emit:
    eggnog_annotations = ch_eggnog_annotations // channel: [ val(meta), path(*.emapper.annotations) ]
    eggnog_orthologs   = ch_eggnog_orthologs   // channel: [ val(meta), path(*.emapper.seed_orthologs) ]
    eggnog_hits        = ch_eggnog_hits        // channel: [ val(meta), path(*.emapper.hits) ]
    versions           = ch_versions           // channel: [ versions.yml ]
}
