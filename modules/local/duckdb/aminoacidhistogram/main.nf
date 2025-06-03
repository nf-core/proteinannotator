process DUCKDB_AMINOACIDHISTOGRAM {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'community.wave.seqera.io/library/duckdb-cli:1.1.3--c5d9961e3b49178e'
    //container 'community.wave.seqera.io/library/duckdb-cli_pip_duckdb-extension-parquet:48635535d267c0b5'
    //container 'community.wave.seqera.io/library/duckdb-cli_pip_duckdb-extension-parquet:be97269b25d3a5b6'
    //container 'community.wave.seqera.io/library/pip_duckdb-extension-parquet_duckdb:8326cfa0a50bf9c9'

    input:
    tuple val(meta), path(parquet)

    output:
    tuple val(meta), path("*.histogram.tsv"), emit: histogram
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def amino_acid_properties = file("${moduleDir}/assets/amino_acid_properties.tsv")
    //template 'amino_acid_histogram.py'
    def sql = "INSTALL parquet; LOAD parquet; COPY (WITH p AS (SELECT * FROM read_parquet('${parquet}/*.parquet')), s AS (SELECT unnest(string_to_array(sequence, '')) AS aa FROM p), h AS (SELECT unnest(map_entries(histogram(aa))) AS kv FROM s), e AS (SELECT * from read_csv_auto('${amino_acid_properties}')) SELECT '${prefix}' AS id, h.kv['value'] AS count, e.* FROM h JOIN e ON h.kv['key'] = e.one_letter_symbol) TO '${prefix}.histogram.tsv' (HEADER, DELIMITER '\t')"
    """
    duckdb :memory: "$sql"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        duckdb: \$( duckdb --version | cut -f 1 -d " " )
    END_VERSIONS
    """
}
