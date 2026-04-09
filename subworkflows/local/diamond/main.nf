include { NCBIREFSEQDOWNLOAD } from '../../../modules/local/ncbirefseqdownload/main'
include { DIAMONDPREPARETAXA } from '../../../modules/local/diamondpreparetaxa/main'
include { DIAMOND_MAKEDB } from '../../../modules/nf-core/diamond/makedb/main'
include { DIAMOND_BLASTP  } from '../../../modules/nf-core/diamond/blastp/main'

workflow DIAMOND {
    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]

    main:

    ch_versions = channel.empty()

    // Local modules of Diamond subworkflow
    NCBIREFSEQDOWNLOAD(
        params.refseq_release
    )
    ch_diamond_reference_fasta = NCBIREFSEQDOWNLOAD.out.refseq_fasta.map { file -> [ [id: 'refseq'], file ] }
    ch_versions = ch_versions.mix(NCBIREFSEQDOWNLOAD.out.versions.first())

    DIAMONDPREPARETAXA (
        params.taxondmp_zip
    )
    ch_taxonnodes = DIAMONDPREPARETAXA.out.taxonnodes
    ch_taxonnames = DIAMONDPREPARETAXA.out.taxonnames
    ch_versions = ch_versions.mix(DIAMONDPREPARETAXA.out.versions.first())

    // Local modules of Diamond subworkflow
    DIAMOND_MAKEDB (
        ch_diamond_reference_fasta,
        params.taxonmap,
        ch_taxonnodes,
        ch_taxonnames
    )
    ch_diamond_db = DIAMOND_MAKEDB.out.db

    DIAMOND_BLASTP (
        ch_fasta,
        ch_diamond_db,
        params.diamond_outfmt,
        params.diamond_blast_columns ?: '',
    )

    emit:
    blast = DIAMOND_BLASTP.out.blast
    xml = DIAMOND_BLASTP.out.xml
    txt = DIAMOND_BLASTP.out.txt
    daa = DIAMOND_BLASTP.out.daa
    sam = DIAMOND_BLASTP.out.sam
    tsv = DIAMOND_BLASTP.out.tsv
    paf = DIAMOND_BLASTP.out.paf
    versions = ch_versions
}
