include { ARIA2 as ARIA2_PFAM                 } from '../../../modules/nf-core/aria2/main'
include { ARIA2 as ARIA2_FUNFAM               } from '../../../modules/nf-core/aria2/main'
include { WGET as WGET_MROOT                  } from '../../../modules/nf-core/wget/main'
include { HMMER_HMMSEARCH as HMMSEARCH_PFAM   } from '../../../modules/nf-core/hmmer/hmmsearch/main'
include { HMMER_HMMSEARCH as HMMSEARCH_FUNFAM } from '../../../modules/nf-core/hmmer/hmmsearch/main'
include { HMMER_HMMSEARCH as HMMSEARCH_MROOT  } from '../../../modules/nf-core/hmmer/hmmsearch/main'
include { UNTAR as UNTAR_MROOT                } from '../../../modules/nf-core/untar/main'

workflow DOMAIN_ANNOTATION {
    take:
    ch_fasta            // channel: [ val(meta), [ fasta ] ]
    skip_pfam           // boolean
    pfam_db             // string, path to the pfam HMM database, if already exists
    pfam_latest_link    // string, path to the latest pfam HMM database, to download
    skip_funfam         // boolean
    funfam_db           // string, path to the funfam HMM database, if already exists
    funfam_latest_link  // string, path to the latest funfam HMM database, to download
    skip_mroot          // boolean
    mroot_db            // string, path to the metagroot HMM database, if already exists
    mroot_latest_link   // string, path to the latest metagroot HMM database, to download

    main:

    ch_versions       = channel.empty()
    ch_pfam_domains   = channel.empty()
    ch_funfam_domains = channel.empty()
    ch_mroot_domains  = channel.empty()

    if (!skip_pfam) {
        if (!pfam_db) {
            ch_pfam_link = channel.of([ [ id: 'pfam' ], pfam_latest_link ])

            ARIA2_PFAM( ch_pfam_link )
            ch_versions = ch_versions.mix( ARIA2_PFAM.out.versions )
            ch_pfam_db = ARIA2_PFAM.out.downloaded_file
        } else {
            ch_pfam_db = channel.of([ [ id: 'pfam' ], pfam_db ])
        }

        ch_input_for_hmmsearch_pfam = ch_fasta
            .combine(ch_pfam_db)
            .map{ meta, seqs, _meta2, models -> [meta, models, seqs, false, false, true] }

        HMMSEARCH_PFAM( ch_input_for_hmmsearch_pfam )
        ch_versions = ch_versions.mix( HMMSEARCH_PFAM.out.versions.first() )
        ch_pfam_domains = HMMSEARCH_PFAM.out.domain_summary
    }

    if (!skip_funfam) {
        if (!funfam_db) {
            ch_funfam_link = channel.of([ [ id: 'funfam' ], funfam_latest_link ])

            ARIA2_FUNFAM( ch_funfam_link )
            ch_versions = ch_versions.mix( ARIA2_FUNFAM.out.versions )
            ch_funfam_db = ARIA2_FUNFAM.out.downloaded_file
        } else {
            ch_funfam_db = channel.of([ [ id: 'funfam' ], funfam_db ])
        }

        ch_input_for_hmmsearch_funfam = ch_fasta
            .combine(ch_funfam_db)
            .map{ meta, seqs, _meta2, models -> [meta, models, seqs, false, false, true] }

        HMMSEARCH_FUNFAM( ch_input_for_hmmsearch_funfam )
        ch_versions = ch_versions.mix( HMMSEARCH_FUNFAM.out.versions.first() )
        ch_funfam_domains = HMMSEARCH_FUNFAM.out.domain_summary
    }

    if (!skip_mroot) {
        if (!mroot_db) {
            ch_mroot_link = channel.of([ [ id: 'mroot' ], mroot_latest_link ])
            // download file from url
            WGET_MROOT( ch_mroot_link )
            // untar file if its a tar.gz
            UNTAR_MROOT( WGET_MROOT.out.outfile )
            // extract hmm files from dir
            ch_mroot_db = UNTAR_MROOT.out.untar
            .map {
                meta, dir ->
                // collect all .hmm files from dir
                def hmm_files = file("${dir}/**/*.hmm")
                tuple(meta, hmm_files)
            }
        } else {
            ch_mroot_db = channel.of([ [ id: 'mroot' ], mroot_db ])
        }

        ch_input_for_hmmsearch_mroot = ch_fasta
            .combine(ch_mroot_db)
            .map{ meta, seqs, _meta2, models -> [meta, models, seqs, false, false, true] }

        HMMSEARCH_MROOT( ch_input_for_hmmsearch_mroot )
        ch_versions = ch_versions.mix( HMMSEARCH_MROOT.out.versions.first() )
        ch_mroot_domains = HMMSEARCH_MROOT.out.domain_summary
    }

    emit:
    pfam_domains   = ch_pfam_domains
    funfam_domains = ch_funfam_domains
    mroot_domains  = ch_mroot_domains
    versions       = ch_versions
}
