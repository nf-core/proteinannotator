include { ARIA2                               } from '../../../modules/nf-core/aria2/main'
include { HMMER_HMMSEARCH as HMMSEARCH_PFAM   } from '../../../modules/nf-core/hmmer/hmmsearch/main'
include { HMMER_HMMSEARCH as HMMSEARCH_FUNFAM } from '../../../modules/nf-core/hmmer/hmmsearch/main'

workflow DOMAIN_ANNOTATION {
    take:
    ch_fasta            // channel: [ val(meta), [ fasta ] ]
    skip_pfam           // boolean
    pfam_latest_link    // string, path to the latest pfam HMM database, to download
    pfam_db             // string, path to the pfam HMM database, if already exists
    skip_funfam         // boolean
    funfam_latest_link  // string, path to the latest funfam HMM database, to download
    funfam_db           // string, path to the funfam HMM database, if already exists

    main:

    ch_versions = channel.empty()

    if (!skip_pfam) {
        if (!pfam_db) {
            ch_pfam_link = channel.of([ [ id: 'pfam' ], pfam_latest_link ])

            ARIA2( ch_pfam_link )
            ch_versions = ch_versions.mix( ARIA2.out.versions )
            ch_pfam_db = ARIA2.out.downloaded_file
        } else {
            ch_pfam_db = channel.of([ [ id: 'pfam' ], pfam_db ])
        }

        ch_input_for_hmmsearch = ch_fasta
            .combine(ch_pfam_db)
            .map{ meta, seqs, _meta2, models -> [meta, models, seqs, false, false, true] }

        HMMSEARCH_PFAM( ch_input_for_hmmsearch )
        ch_versions = ch_versions.mix( HMMSEARCH_PFAM.out.versions.first() )
    }

    if (!skip_funfam) {
        if (!funfam_db) {
            ch_funfam_link = channel.of([ [ id: 'funfam' ], funfam_latest_link ])

            ARIA2( ch_funfam_link )
            ch_versions = ch_versions.mix( ARIA2.out.versions )
            ch_funfam_db = ARIA2.out.downloaded_file
        } else {
            ch_funfam_db = channel.of([ [ id: 'funfam' ], funfam_db ])
        }

        ch_input_for_hmmsearch = ch_fasta
            .combine(ch_funfam_db)
            .map{ meta, seqs, _meta2, models -> [meta, models, seqs, false, false, true] }

        HMMSEARCH_FUNFAM( ch_input_for_hmmsearch )
        ch_versions = ch_versions.mix( HMMSEARCH_FUNFAM.out.versions.first() )
    }

    emit:
    pfam_domains   = HMMSEARCH_PFAM.out.domain_summary
    funfam_domains = HMMSEARCH_FUNFAM.out.domain_summary
    versions       = ch_versions
}
