process UNIFIRE_PIRSR {
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
    path(pirsr_data)

    output:
    tuple val(meta), path("${meta.id}/*fasta-urml.xml"), emit: fact_xml
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // this is the commit hash of https://gitlab.ebi.ac.uk/uniprot-public/unifire/-/tree/master?ref_type=heads from which the biocontainers package was built
    def VERSION="325ee7c7"
    """
    # note: the `-a` argument is configured to a default in the bioconda environment
    # and biocontainers images.

    mkdir -p ${prefix}

    pirsr \\
        -i ${interproscan_xml} \\
        -o ${prefix} \\
        -d ${pirsr_data} \\
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
    mkdir -p ${prefix}
    touch ${prefix}/input_ipr.fasta-urml.xml

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        unifire: ${VERSION}
    END_VERSIONS
    """
}
