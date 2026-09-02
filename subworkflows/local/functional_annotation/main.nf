include { ARIA2 as ARIA2_INTERPROSCAN               } from '../../../modules/nf-core/aria2/main'
include { ARIA2 as ARIA2_KOFAM_PROFILES             } from '../../../modules/nf-core/aria2/main'
include { ARIA2 as ARIA2_KOFAM_KO_LIST              } from '../../../modules/nf-core/aria2/main'
include { UNTAR as UNTAR_INTERPROSCAN               } from '../../../modules/nf-core/untar/main'
include { UNTAR as UNTAR_KOFAM_PROFILES             } from '../../../modules/nf-core/untar/main'
include { GUNZIP as GUNZIP_KOFAM_KO_LIST            } from '../../../modules/nf-core/gunzip/main'
include { INTERPROSCAN                              } from '../../../modules/nf-core/interproscan/main'
include { KOFAMSCAN                                 } from '../../../modules/nf-core/kofamscan/main'

workflow FUNCTIONAL_ANNOTATION {
    take:
    ch_fasta               // channel: [ val(meta), path(fasta) ]
    skip_interproscan      // boolean
    interproscan_db_url    // string, URL to download database
    interproscan_db        // string, existing database
    skip_kofamscan         // boolean
    kofamscan_profiles_url // string, URL to download KOfam profiles
    kofamscan_profiles     // string, existing KOfam profiles directory
    kofamscan_ko_list_url  // string, URL to download KOfam KO list
    kofamscan_ko_list      // string, existing KOfam KO list

    main:
    def ch_interproscan_tsv = channel.empty()
    def ch_kofamscan_tsv    = channel.empty()

    if (!skip_interproscan) {
        def ch_interproscan_db
        if (interproscan_db) {
            ch_interproscan_db = channel.fromPath(interproscan_db, checkIfExists: true).first()
        }
        else {
            ARIA2_INTERPROSCAN( [ [ id: 'interproscan_db' ], interproscan_db_url ] )
            UNTAR_INTERPROSCAN( ARIA2_INTERPROSCAN.out.downloaded_file )
            ch_interproscan_db = UNTAR_INTERPROSCAN.out.untar
                .map { _meta, database -> database }
                .first()
        }

        INTERPROSCAN( ch_fasta, ch_interproscan_db )
        ch_interproscan_tsv = INTERPROSCAN.out.tsv
    }

    if (!skip_kofamscan) {
        def ch_kofamscan_profiles
        if (kofamscan_profiles) {
            ch_kofamscan_profiles = channel.fromPath(kofamscan_profiles, checkIfExists: true).first()
        }
        else {
            ARIA2_KOFAM_PROFILES( [ [ id: 'kofamscan_profiles' ], kofamscan_profiles_url ] )
            UNTAR_KOFAM_PROFILES( ARIA2_KOFAM_PROFILES.out.downloaded_file )
            ch_kofamscan_profiles = UNTAR_KOFAM_PROFILES.out.untar
                .map { _meta, profiles -> profiles }
                .first()
        }

        def ch_kofamscan_ko_list
        if (kofamscan_ko_list) {
            ch_kofamscan_ko_list = channel.fromPath(kofamscan_ko_list, checkIfExists: true).first()
        }
        else {
            ARIA2_KOFAM_KO_LIST( [ [ id: 'kofamscan_ko_list' ], kofamscan_ko_list_url ] )
            GUNZIP_KOFAM_KO_LIST( ARIA2_KOFAM_KO_LIST.out.downloaded_file )
            ch_kofamscan_ko_list = GUNZIP_KOFAM_KO_LIST.out.gunzip
                .map { _meta, ko_list -> ko_list }
                .first()
        }

        KOFAMSCAN( ch_fasta, ch_kofamscan_profiles, ch_kofamscan_ko_list )
        ch_kofamscan_tsv = KOFAMSCAN.out.tsv
    }

    emit:
    interproscan_tsv = ch_interproscan_tsv
    kofamscan_tsv    = ch_kofamscan_tsv
}
