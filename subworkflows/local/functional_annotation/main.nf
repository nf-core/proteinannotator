// Import Annotator Subworfklows
include { BLASTP                } from '../blastp/main'


workflow FUNCTIONAL_ANNOTATION {

    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow

    // Create a multifasta, with one fasta per entry, add the sequence ID to the meta id
    ch_fasta
        .map {
            meta, fasta ->
            [
                [id:"${meta.id}_${fasta.splitFasta(record: [id: true]).id[0].replaceAll(/\|/, '-')}"] ,
                fasta.splitFasta(file:true)
            ]
        }
        .transpose()
        .set { ch_multifasta }

    //
    // SUBWORKFLOW: BLASTP
    //
    BLASTP (
    ch_multifasta, params.blastp_outfmt
    )
    ch_versions = ch_versions.mix(BLASTP.out.versions.first())


    emit:
    // TODO nf-core: edit emitted channels

    multifasta = ch_multifasta
    versions   = ch_versions                     // channel: [ versions.yml ]
}
