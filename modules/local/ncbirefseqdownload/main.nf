process NCBIREFSEQDOWNLOAD {
    label 'process_low'
    tag "download_refseq"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-stitch:1.7.3--r44h64f727c_0':
        'biocontainers/r-stitch:1.7.3--r44h64f727c_0' }"

    input:
    val(refseq_release) // ncbi refseq release category -- default of 'complete'

    output:
    path "ncbi_refseq/refseq_fasta.fa.gz", emit: refseq_fasta // reference fasta for diamond/makedb nf-core module
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
    """
    touch ncbi_refseq/refseq_fastas.fa.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}"
        rsync: "stub"
    END_VERSIONS
    """
}