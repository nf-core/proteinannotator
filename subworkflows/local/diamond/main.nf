// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules
include { NCBIREFSEQDOWNLOAD } from '../../../modules/local/ncbirefseqdownload/main'
include { DIAMONDPREPARETAXA } from '../../../modules/local/diamondpreparetaxa/main'
include { DIAMOND_MAKEDB } from '../../../modules/nf-core/diamond/makedb/main'
include { DIAMOND_BLASTP  } from '../../../modules/nf-core/diamond/blastp/main'

/*
* Pipeline parameters
*/
// params.refseq_release = 'complete'
// params.taxondmp_zip = 'ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz'
// params.taxonmap = 'ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz'
// params.diamond_outfmt = 6
// params.diamond_blast_columns = qseqid

workflow DIAMOND {
    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow
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


    DIAMOND_MAKEDB (
        ch_diamond_reference_fasta,
        params.taxonmap, // make default ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/prot.accession2taxid.gz
        ch_taxonnodes,
        ch_taxonnames
    )
    // ch_diamond_db = DIAMOND_MAKEDB.out.db.map { db -> [ [id: 'diamond_db'], db ]}
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
    blast = DIAMOND_BLASTP.out.blast
    sml = DIAMOND_BLASTP.out.xml
    txt = DIAMOND_BLASTP.out.txt
    daa = DIAMOND_BLASTP.out.daa
    sam = DIAMOND_BLASTP.out.sam
    tsv = DIAMOND_BLASTP.out.tsv
    paf = DIAMOND_BLASTP.out.paf
    versions = ch_versions

    // // Create a multifasta, with one fasta per entry, add the sequence ID to the meta id
    // ch_fasta
    //     .map {
    //         meta, fasta ->
    //         [
    //             [id:"${meta.id}_${fasta.splitFasta(record: [id: true]).id[0].replaceAll(/\|/, '-')}"] ,
    //             fasta.splitFasta(file:true)
    //         ]
    //     }
    //     .transpose()
    //     .set { ch_multifasta }

    // //
    // // SUBWORKFLOW: Annotator Name
    // //

    // emit:
    // // TODO nf-core: edit emitted channels
    // ch_diamond_tsv = DIAMOND_BLASTP.out.tsv    // channel: [ val(meta)]

    // multifasta = ch_multifasta
    // versions   = ch_versions                     // channel: [ versions.yml ]
}
