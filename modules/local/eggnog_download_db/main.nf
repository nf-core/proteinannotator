process EGGNOG_DOWNLOAD_DB {
    tag "eggnog_db_download"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/eggnog-mapper:2.1.12--pyhdfd78af_0':
        'biocontainers/eggnog-mapper:2.1.12--pyhdfd78af_0' }"

    input:
    val(download_databases)

    output:
    path("eggnog_data")         , emit: data_dir
    path("eggnog_data/*.db")    , emit: db, optional: true
    path("eggnog_data/*.dmnd")  , emit: diamond_db
    path "versions.yml"         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    mkdir -p eggnog_data

    # Download eggNOG databases
    # -y: auto-yes to prompts
    # -F: install novel families (optional, can be controlled via args)
    download_eggnog_data.py \\
        --data_dir eggnog_data \\
        -y \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eggnog-mapper: \$(echo \$(emapper.py --version) | grep -o "emapper-[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+" | sed "s/emapper-//")
    END_VERSIONS
    """

    stub:
    """
    mkdir -p eggnog_data
    touch eggnog_data/eggnog.db
    touch eggnog_data/eggnog_proteins.dmnd

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        eggnog-mapper: \$(echo \$(emapper.py --version) | grep -o "emapper-[0-9]\\+\\.[0-9]\\+\\.[0-9]\\+" | sed "s/emapper-//")
    END_VERSIONS
    """
}
