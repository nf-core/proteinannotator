// Import Annotator Subworfklows
include { INTERPROSCAN } from '../interproscan/main'


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

    emit:
    versions = ch_versions // channel: [ versions.yml ]
}
