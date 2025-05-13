// Import Interproscan Subworfklow
include { INTERPROSCAN                } from '../interproscan/main'



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
                [id:"${meta.id}_${fasta[0].splitFasta(record: [id: true]).id[0].replaceAll(/\|/, '-')}"] ,
                fasta[0].splitFasta(file:true)
            ]
        }
        .transpose()
        .view()
        .set { ch_multifasta }

    //
    // SUBWORKFLOW: Run InterProScan
    //

    INTERPROSCAN (
        ch_multifasta,
        [file(params.interproscan_database, checkIfExists: true), params.interproscan_database_version],
    )
    ch_versions = ch_versions.mix(INTERPROSCAN.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels

    versions = ch_versions                     // channel: [ versions.yml ]
}

