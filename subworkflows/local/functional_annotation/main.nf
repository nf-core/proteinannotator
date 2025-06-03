include { DIAMOND_BLASTP  } from '../../../modules/nf-core/diamond/blastp/main'
include { DIAMOND_MAKEDB } from '../../../modules/nf-core/diamond/makedb/main'
// include { BLAST_MAKEBLASTDB } from '../../../modules/nf-core/blast/makeblastdb/main'
include { NCBIREFSEQDOWNLOAD } from '../../../modules/local/ncbirefseqdownload/main'

workflow FUNCTIONAL_ANNOTATION {

    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow
    NCBIREFSEQDOWNLOAD() // may need to include an input, currently uses default categories def categories = task.ext.categories ?: ['vertebrate_mammalian', 'vertebrate_other', 'invertebrate']
    ch_diamond_reference_fasta = NCBIREFSEQDOWNLOAD.out.fasta
    ch_versions = ch_versions.mix(NCBIREFSEQDOWNLOAD.out.versions.first())

    DIAMOND_MAKEDB (
        ch_diamond_reference_fasta,
    )

    ch_diamond_db = DIAMOND_MAKEDB.out.db
    ch_versions = ch_versions.mix(DIAMOND_MAKEDB.out.versions.first())


    //ch_diamond_db = Channel.of( [ [id:"diamond_db"], file(params.diamond_db, checkIfExists: true) ] )

    DIAMOND_BLASTP (
        ch_fasta,
        ch_diamond_db,
        params.diamond_outfmt,
        params.diamond_blast_columns,
    )
    ch_versions = ch_versions.mix(DIAMOND_BLASTP.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels
    ch_diamond_tsv = DIAMOND_BLASTP.out.tsv    // channel: [ val(meta)]

    versions = ch_versions                     // channel: [ versions.yml ]
}

