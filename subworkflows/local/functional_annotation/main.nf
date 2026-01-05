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

    EGGNOG(
        ch_multifasta
    )
    ch_versions = ch_versions.mix(EGGNOG.out.versions)

    emit:
    eggnog_annotations = EGGNOG.out.annotations // channel: [ val(meta), path(*.emapper.annotations) ]
    eggnog_orthologs   = EGGNOG.out.orthologs   // channel: [ val(meta), path(*.emapper.seed_orthologs) ]
    eggnog_hits        = EGGNOG.out.hits        // channel: [ val(meta), path(*.emapper.hits) ]
    versions           = ch_versions            // channel: [ versions.yml ]
}
