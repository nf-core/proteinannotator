process NCBIREFSEQDOWNLOAD {
    label 'process_low'
    tag "download_refseq"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'biocontainers/YOUR-TOOL-HERE' }"

    // publishDir "${params.outdir}", mode: 'copy'

    input:
    val(refseq_release) // ncbi refseq release category --  add default of 'complete'

    output:
    path "ncbi_refseq/refseq_fasta.fa.gz", emit: refseq_fasta // reference fasta for diamond/makedb
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    mkdir -p ncbi_refseq/${refseq_release}/

    rsync \\
        -av \\
        --include '*protein.faa.gz' \\
        --exclude '*' \\
        rsync://ftp.ncbi.nlm.nih.gov/refseq/release/${refseq_release}/ \\
        ncbi_refseq/${refseq_release}/

    zcat ncbi_refseq/*/*.faa.gz | gzip -c > ncbi_refseq/refseq_fasta.fa.gz

    echo "All RefSeq protein FASTAs aggregated into ncbi_refseq/"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rsync: \$(rsync --version | head -n1 | sed 's/rsync  version //')
    END_VERSIONS
    """

    stub:
    // def args = task.ext.args ?: ''
    // def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    touch ncbi_refseq/refseq_fastas.fa.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}"
        rsync: "stub"
    END_VERSIONS
    """
}