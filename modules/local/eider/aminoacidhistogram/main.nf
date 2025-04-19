process EIDER_AMINOACIDHISTOGRAM {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/eider:0.1--hdfd78af_0' :
        'biocontainers/eider:0.1--hdfd78af_0' }"

    input:
    tuple val(meta), path(parquet)

    output:
    tuple val(meta), path("*.histogram.tsv"), emit: histogram
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def amino_acid_properties = file("${moduleDir}/assets/amino_acid_properties.tsv")
    def query_template = file("${moduleDir}/assets/query_template.sql")
    """
    eider \
        $args \
        --verbose \
        --skip-history \
        --parameters prefix=${prefix} \
        --parameters amino_acid_properties=${amino_acid_properties} \
        --query-path ${query_template}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eider: \$(eider --version 2>&1 | grep -o 'eider .*' | cut -f2 -d ' ')
    END_VERSIONS
    """
}
