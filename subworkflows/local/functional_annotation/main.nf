include { ARIA2        } from '../../../modules/nf-core/aria2/main'
include { UNTAR        } from '../../../modules/nf-core/untar/main'
include { INTERPROSCAN } from '../../../modules/nf-core/interproscan/main'

process CONCAT_TSV {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(tsvs)

    output:
    tuple val(meta), path("${meta.id}_interproscan.tsv"), emit: tsv

    script:
    """
    cat ${tsvs} > ${meta.id}_interproscan.tsv
    """
}

workflow FUNCTIONAL_ANNOTATION {
    take:
    ch_fasta                // channel: [ val(meta), [ fasta ] ]
    skip_interproscan       // boolean
    interproscan_db_url     // string, url to download db
    interproscan_db         // string, existing db
    interproscan_batch_size // integer, number of sequences per batch

    main:
    ch_interproscan_tsv = channel.empty()
    ch_versions         = channel.empty()

    if (!skip_interproscan) {
        if (interproscan_db) {
            ch_interproscan_db = channel.fromPath(interproscan_db).first()
        }
        else {
            ARIA2( [ [ id:'interproscan_db' ], interproscan_db_url ] )
            ch_versions = ch_versions.mix(ARIA2.out.versions.first())

            UNTAR( ARIA2.out.downloaded_file )
            ch_interproscan_db = UNTAR.out.untar.map{ f -> f[1] }
        }

        // Split FASTA into batches for parallel InterProScan processing
        ch_fasta_batched = ch_fasta
            .flatMap { meta, fasta ->
                def chunks = fasta.splitFasta(by: interproscan_batch_size, file: true)
                if (chunks instanceof Path) {
                    // Single chunk (fewer sequences than batch size)
                    return [[ meta, chunks ]]
                }
                chunks.withIndex().collect { chunk, idx ->
                    def new_meta = meta.clone()
                    new_meta.original_id = meta.id
                    new_meta.id = "${meta.id}_batch${idx}"
                    [ new_meta, chunk ]
                }
            }

        INTERPROSCAN( ch_fasta_batched, ch_interproscan_db )

        // Regroup batch TSV results by original sample ID
        ch_batched_tsv = INTERPROSCAN.out.tsv
            .map { meta, tsv ->
                def original_id = meta.original_id ?: meta.id
                [ [id: original_id], tsv ]
            }
            .groupTuple()

        // Concatenate batch TSVs into one file per sample
        CONCAT_TSV( ch_batched_tsv )
        ch_interproscan_tsv = CONCAT_TSV.out.tsv
    }

    emit:
    interproscan_tsv = ch_interproscan_tsv
    versions         = ch_versions         // channel: [ versions.yml ]
}
