include { DIAMOND_BLASTP  } from '../../../modules/nf-core/diamond/blastp/main'
include { DIAMOND_MAKEDB } from '../../../modules/nf-core/diamond/makedb/main'
// include { BLAST_MAKEBLASTDB } from '../../../modules/nf-core/blast/makeblastdb/main'
include { NCBIREFSEQDOWNLOAD } from '../../../modules/local/ncbirefseqdownload/main'

// Import Annotator Subworfklows
include { INTERPROSCAN } from '../interproscan/main'


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



    emit:
    // TODO nf-core: edit emitted channels
    ch_diamond_tsv = DIAMOND_BLASTP.out.tsv    // channel: [ val(meta)]
    emit:
    versions = ch_versions // channel: [ versions.yml ]
    
    //
    // SUBWORKFLOW: Run InterProScan
    //

    if (!params.skip_interproscan) {
        INTERPROSCAN(
            ch_multifasta
        )
        ch_versions = ch_versions.mix(INTERPROSCAN.out.versions.first())
    }
}
