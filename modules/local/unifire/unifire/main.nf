process UNIFIRE_UNIFIRE {
    tag "$meta.id"
    label 'process_single'

    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
    //     'biocontainers/YOUR-TOOL-HERE' }"

    // until the bioconda recipe is pushed. See https://github.com/bioconda/bioconda-recipes/pull/56175
    container 'docker.io/cmatkhan/unifire_bioconda_tmp:latest'

    input:
    tuple val(meta), path(interproscan_xml)
    path(urml_rules)
    path(template)

    output:
    tuple val(meta), path("*_unifire.csv"), emit: predictions
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Only add -t if template is not NO_FILE
    def template_flag = template ? "-t ${template}" : ''
    def input_source = meta.input_source ?: 'InterProScan'
    def prefix = task.ext.prefix ?: "${meta.id}"
    def output_filename = task.ext.prefix
            ? "${prefix}_unifire.csv"
            : "${prefix}_${urml_rules.getSimpleName()}_unifire.csv"
    def max_memory = task.ext.max_memory ?: task.max_memory
    def args = task.ext.args ?: ''
    def VERSION="325ee7c7"
    """
    unifire \\
        -r ${urml_rules} \\
        -i ${interproscan_xml} \\
        ${template_flag} \\
        -s ${input_source} \\
        -o ${output_filename} \\
        -m ${max_memory} \\
        ${args}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        unifire: ${VERSION}
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION="325ee7c7"
    """
    touch ${prefix}_unifire.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        unifire: ${VERSION}
    END_VERSIONS
    """
}
