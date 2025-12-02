include { ARIA2           } from '../../../modules/nf-core/aria2/main'
include { HMMER_HMMSEARCH } from '../../../modules/nf-core/hmmer/hmmsearch/main'

workflow DOMAIN_ANNOTATION {
    take:
    ch_fasta          // channel: [ val(meta), [ fasta ] ]
    skip_pfam         // boolean
    pfam_latest_link  // string, path to the latest pfam HMM database, to download
    pfam_db           // string, path to the pfam HMM database, if already exists

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

        HMMER_HMMSEARCH( ch_input_for_hmmsearch )
        ch_versions = ch_versions.mix( HMMER_HMMSEARCH.out.versions.first() )
    }

    emit:
    pfam_domains = HMMER_HMMSEARCH.out.domain_summary
    versions     = ch_versions
}
