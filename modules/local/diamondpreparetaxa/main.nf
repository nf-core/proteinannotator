// TODO nf-core: If in doubt look at other nf-core/modules to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/modules/nf-core/
//               You can also ask for help via your pull request or on the #modules channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A module file SHOULD only define input and output files as command-line parameters.
//               All other parameters MUST be provided using the "task.ext" directive, see here:
//               https://www.nextflow.io/docs/latest/process.html#ext
//               where "task.ext" is a string.
//               Any parameters that need to be evaluated in the context of a particular sample
//               e.g. single-end/paired-end data MUST also be defined and evaluated appropriately.
// TODO nf-core: Software that can be piped together SHOULD be added to separate module files
//               unless there is a run-time, storage advantage in implementing in this way
//               e.g. it's ok to have a single module for bwa to output BAM instead of SAM:
//                 bwa mem | samtools view -B -T ref.fasta
// TODO nf-core: Optional inputs are not currently supported by Nextflow. However, using an empty
//               list (`[]`) instead of a file can be used to work around this issue.


process DIAMONDPREPARETAXA {
    // tag "${taxondmp_zip.baseName}"
    // label "process_low"

    // publishDir "${params.outdir}/ncbi_refseq/", mode: 'copy'

    // input:
    // file(taxondmp_zip) from ch_diamond_taxdmp_zip

    // output:
    // file("nodes.dmp") into ch_diamond_taxonnodes
    // file("names.dmp") into ch_diamond_taxonnames

    // script:
    // """
    // 7z x ${taxondmp_zip}
    // """
    
    tag "${taxondmp_zip.baseName}"
    label 'process_low'

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/YOUR-TOOL-HERE':
        'biocontainers/YOUR-TOOL-HERE' }"


    
    // write the output files to a user specified directory via an input parameter
    publishDir "${params.outdir}/ncbi_refseq/", mode: 'copy'

    input:
    // if (params.taxdmp_zip) {
    // Channel.fromPath(params.taxdmp_zip, checkIfExists: true)
    //     .ifEmpty { exit 1, "Diamond taxon dump file not found: ${params.taxdmp_zip}" }
    //     .set{ ch_diamond_taxdmp_zip }
    // }
    path taxondmp_zip //from ch_diamond_taxdmp_zip

    output:
    tuple val(meta), path("nodes.dmp"), emit: taxonnodes
    tuple val(meta), path("names.dmp"), emit: taxonnames
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    diamondpreparetaxa \\
        $args \\
        -@ $task.cpus \\
        -o ${prefix}.bam \\
        7z x ${taxondmp_zip}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamondpreparetaxa: \$(diamondpreparetaxa --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamondpreparetaxa: \$(diamondpreparetaxa --version)
    END_VERSIONS
    """
}
