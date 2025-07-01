process INTERPROSCAN {
    scratch true
    tag "${meta.id}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "nf-core/interproscan:5.73-104.0"
    containerOptions {
        if (workflow.containerEngine in ['singularity', 'apptainer']) {
            return "--bind data:/opt/interproscan/data"
        }
        else {
            return '-v ./data:/opt/interproscan/data'
        }
    }

    input:
    tuple val(meta), path(fasta)
    tuple path(interproscan_db, stageAs: "data"), val(db_version)

    output:
    tuple val(meta), path('*.tsv.gz'), emit: tsv
    tuple val(meta), path('*.xml.gz'), emit: xml
    tuple val(meta), path('*.gff3.gz'), emit: gff3
    tuple val(meta), path('*.json.gz'), emit: json
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // -dp (disable precalculation) is on so no online dependency
    """
    # Find interproscan.properties to link data/ from work directory
    INTERPROSCAN_DIR="\$( dirname "\$( dirname "\$( which interproscan.sh )" )" )"
    INTERPROSCAN_PROPERTIES="\$( find "\$INTERPROSCAN_DIR/" -name "interproscan.properties" )"
    cp "\$INTERPROSCAN_PROPERTIES" .
    sed -i "/^bin\\.directory=/ s|.*|bin.directory=\$INTERPROSCAN_DIR/bin|" interproscan.properties
    export INTERPROSCAN_CONF=interproscan.properties

    ls -lha
    echo interproscan_db "${interproscan_db}"
    ls -lha ${interproscan_db}
    interproscan.sh \\
        --verbose \\
        -cpu ${task.cpus} \\
        -i ${fasta} \\
        -dp \\
        ${args} \\
        --output-file-base ${prefix}

    gzip ${prefix}.{tsv,xml,gff3,json}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        InterProScan: \$(interproscan.sh --version | grep -o "InterProScan version [0-9.-]*" | sed "s/InterProScan version //")
        InterProScan database: ${db_version}
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.{tsv,xml,gff3,json}
    gzip ${prefix}.{tsv,xml,gff3,json}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        InterProScan: \$(interproscan.sh --version | grep -o "InterProScan version [0-9.-]*" | sed "s/InterProScan version //")
        InterProScan database: ${db_version}
    END_VERSIONS
    """
}
