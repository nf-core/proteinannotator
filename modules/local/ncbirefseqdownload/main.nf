process NCBIREFSEQDOWNLOAD {
    label 'process_low'
    tag "download_refseq"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/rsync:3.4.4--e7cdbdef11f909e3' :
        'community.wave.seqera.io/library/rsync:3.4.4--c47965c3c662c89a' }"

    input:
    val(refseq_release) // ncbi refseq release category -- default of 'complete'

    output:
    path "ncbi_refseq/refseq_fasta.fa.gz", emit: refseq_fasta // reference fasta for diamond/makedb nf-core module
    tuple val("${task.process}"), val('rsync'), eval('rsync --version | head -n1 | sed \'s/rsync  version //\''), topic: versions, emit: versions_rsync

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
    """

    stub:
    """
    mkdir -p ncbi_refseq
    echo "" | gzip > ncbi_refseq/refseq_fasta.fa.gz
    """
}