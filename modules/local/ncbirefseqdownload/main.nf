process NCBIREFSEQDOWNLOAD {
    label 'process_low'
    tag "download_refseq"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/ca-certificates_rclone:c3d926a2a2b1e656' :
        'community.wave.seqera.io/library/ca-certificates_rclone:ebc43190fc56df7c' }"

    input:
    val(refseq_release) // ncbi refseq release category -- default of 'complete'

    output:
    path "ncbi_refseq/refseq_fasta.fa.gz", emit: refseq_fasta // reference fasta for diamond/makedb nf-core module
    tuple val("${task.process}"), val('rclone'), eval('rclone --version | head -n1 | sed "s/rclone //"'), topic: versions, emit: versions_rclone

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    if [ -f /opt/conda/ssl/cacert.pem ]; then
        export SSL_CERT_FILE=/opt/conda/ssl/cacert.pem
    fi
    mkdir -p ncbi_refseq/${refseq_release}/

    rclone copy \\
        :http:refseq/release/${refseq_release}/ \\
        ncbi_refseq/${refseq_release}/ \\
        --http-url https://ftp.ncbi.nlm.nih.gov \\
        --include '*protein.faa.gz' \\
        --user-agent "Mozilla/5.0"

    zcat ncbi_refseq/*/*.faa.gz | gzip -c > ncbi_refseq/refseq_fasta.fa.gz

    echo "All RefSeq protein FASTAs aggregated into ncbi_refseq/"
    """

    stub:
    """
    mkdir -p ncbi_refseq
    echo "" | gzip > ncbi_refseq/refseq_fasta.fa.gz
    """
}