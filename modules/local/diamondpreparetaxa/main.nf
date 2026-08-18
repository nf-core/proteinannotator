process DIAMONDPREPARETAXA {

    tag "taxdump"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/diamond:2.1.12--hdb4b4cc_1' :
        'biocontainers/diamond:2.1.12--hdb4b4cc_1'}"
    // Note: diamond container is used here for convenience (includes wget/tar);
    // a minimal linux container would be more correct for this download-only process.

    input:
    val taxondmp_zip // NCBI taxonomy dump URL; default: ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

    output:
    path "taxa/nodes.dmp", emit: taxonnodes
    path "taxa/names.dmp", emit: taxonnames
    tuple val("${task.process}"), val('wget'), eval('wget --version | head -n1 | sed "s/GNU Wget //" | sed "s/ .*//"'), topic: versions, emit: versions_wget

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    mkdir -p taxa/
    wget -q ${taxondmp_zip}
    tar -xzf taxdump.tar.gz -C taxa/
    """

    stub:
    """
    mkdir -p taxa/
    touch taxa/nodes.dmp
    touch taxa/names.dmp
    """
}