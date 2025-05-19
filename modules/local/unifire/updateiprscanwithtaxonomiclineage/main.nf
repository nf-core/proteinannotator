process UNIFIRE_UPDATEIPRSCANWITHTAXONOMICLINEAGE {
    tag "$meta.id"
    label 'process_single'

    // conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
    //     'biocontainers/YOUR-TOOL-HERE' }"

    // until the bioconda recipe is pushed. See https://github.com/bioconda/bioconda-recipes/pull/56175
    // TODO before pushing to bioconda, re-consider putting this script in. it
    // made the image much larger. Consider removing it back to the /bin here and
    // making a seqera container docker/singularity for it. both deps (ete4 and lxml)
    // are in conda-forge
    container 'docker.io/cmatkhan/unifire_bioconda_tmp:latest'

    input:
    tuple val(meta), path(interproscan_xml)
    path(taxadb)

    output:
    tuple val(meta), path("*_with_lineage.xml"), emit: xml
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // this is the commit hash of
    // https://gitlab.ebi.ac.uk/uniprot-public/unifire/-/tree/master?ref_type=heads
    // from which the biocontainers package was built
    def VERSION="325ee7c7"
    """
    updateIPRScanWithTaxonomicLineage \\
        -i ${interproscan_xml} \\
        -o ${prefix}_with_lineage.xml \\
        -t ${taxadb} \\
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
    touch ${prefix}_with_lineage.xml

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        unifire: ${VERSION}
    END_VERSIONS
    """
}
