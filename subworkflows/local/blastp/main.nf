// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { BLAST_MAKEBLASTDB       } from '../../../modules/nf-core/blast/makeblastdb/main'
include { BLAST_BLASTP            } from '../../../modules/nf-core/blast/blastp/main'

workflow BLASTP {

    take:
    ch_fasta // channel: [ val(meta), [ fasta ] ]
    blastp_outfmt

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow
    makeblastdb_input = file("${params.blast_ref_fasta}")
    BLAST_MAKEBLASTDB ( [ [ id: makeblastdb_input.getSimpleName() ] , makeblastdb_input] )
    ch_versions = ch_versions.mix(BLAST_MAKEBLASTDB.out.versions)

    BLAST_BLASTP ( ch_fasta, BLAST_MAKEBLASTDB.out.db, blastp_outfmt)
    ch_versions = ch_versions.mix(BLAST_BLASTP.out.versions)


    emit:
    xml      = BLAST_BLASTP.out.xml           // channel: [ val(meta), [ xml ] ]
    csv      = BLAST_BLASTP.out.csv           // channel: [ val(meta), [ csv ] ]
    tsv      = BLAST_BLASTP.out.tsv           // channel: [ val(meta), [ tsv ] ]

    versions = ch_versions              // channel: [ versions.yml ]
}

