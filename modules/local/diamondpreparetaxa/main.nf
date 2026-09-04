process DIAMONDPREPARETAXA {

    tag "taxdump"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/52/52ccce28d2ab928ab862e25aae26314d69c8e38bd41ca9431c67ef05221348aa/data'
        : 'community.wave.seqera.io/library/coreutils_grep_gzip_lbzip2_pruned:838ba80435a629f8'}"

    input:
    path taxondmp_zip // NCBI taxonomy dump URL; default: ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

    output:
    path "taxa/nodes.dmp", emit: taxonnodes
    path "taxa/names.dmp", emit: taxonnames
    tuple val("${task.process}"), val('tar'), eval('tar --version 2>&1 | head -1 | sed "s/tar (GNU tar) //; s/ Copyright.*//"'), emit: versions_tar, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    mkdir -p taxa/
    tar -xzf ${taxondmp_zip} -C taxa/
    """

    stub:
    """
    mkdir -p taxa/
    touch taxa/nodes.dmp
    touch taxa/names.dmp
    """
}