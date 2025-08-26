process DIAMONDPREPARETAXA {
    
    // tag "${taxondmp_zip.baseName}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ? 
        'https://depot.galaxyproject.org/singularity/diamond:2.1.12--hdb4b4cc_1' : 
        'biocontainers/diamond:2.1.12--hdb4b4cc_1'}"

    input:
    val taxondmp_zip // default of ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

    output:
    path("taxa/nodes.dmp"), emit: taxonnodes
    path("taxa/names.dmp"), emit: taxonnames
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """ 
    mkdir -p taxa/
    wget -q ${taxondmp_zip}
    tar -xzf taxdump.tar.gz -C taxa

        cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamondpreparetaxa: \$(diamondpreparetaxa --version)
    END_VERSIONS
    """

    stub:
    """
    touch taxa/nodes.dmp
    touch taxa/names.dmp

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamondpreparetaxa: \$(diamondpreparetaxa --version)
    END_VERSIONS
    """
}
