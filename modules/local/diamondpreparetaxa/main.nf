process DIAMONDPREPARETAXA {
    
    // tag "${taxondmp_zip.baseName}"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/diamond:2.1.12--hdb4b4cc_1'
        : 'biocontainers/diamond:2.1.12--hdb4b4cc_1'}"
        'biocontainers/YOUR-TOOL-HERE' }"

    // write the output files to a user specified directory via an input parameter
    // publishDir "${params.outdir}/ncbi_refseq/", mode: 'copy'

    input:
    val taxondmp_zip // Add default of ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

    output:
    path("taxa/nodes.dmp"), emit: taxonnodes
    path("taxa/names.dmp"), emit: taxonnames
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta.id}"
    // Omitting from script portion for now
        // # $args \\
        // # -@ $task.cpus \\
        // # -o ${prefix}.bam \\

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
    // def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch taxa/nodes.dmp
    touch taxa/names.dmp

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamondpreparetaxa: \$(diamondpreparetaxa --version)
    END_VERSIONS
    """
}
