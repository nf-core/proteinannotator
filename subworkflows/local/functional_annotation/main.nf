// Import Annotator Subworkflows
include { INTERPROSCAN } from '../interproscan/main'
include { EGGNOG } from '../eggnog/main'


workflow FUNCTIONAL_ANNOTATION {
    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]

    main:

    ch_versions = Channel.empty()

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
    // SUBWORKFLOW: Run eggNOG-mapper
    //

    ch_eggnog_annotations = Channel.empty()
    ch_eggnog_orthologs = Channel.empty()
    ch_eggnog_hits = Channel.empty()

    if (!params.skip_eggnog) {
        EGGNOG(
            ch_multifasta
        )
        ch_eggnog_annotations = EGGNOG.out.annotations
        ch_eggnog_orthologs = EGGNOG.out.orthologs
        ch_eggnog_hits = EGGNOG.out.hits
        ch_versions = ch_versions.mix(EGGNOG.out.versions)
    }

    emit:
    eggnog_annotations = ch_eggnog_annotations // channel: [ val(meta), path(*.emapper.annotations) ]
    eggnog_orthologs   = ch_eggnog_orthologs   // channel: [ val(meta), path(*.emapper.seed_orthologs) ]
    eggnog_hits        = ch_eggnog_hits        // channel: [ val(meta), path(*.emapper.hits) ]
    versions           = ch_versions           // channel: [ versions.yml ]
}
