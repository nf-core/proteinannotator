include { UNIFIRE_UPDATEIPRSCANWITHTAXONOMICLINEAGE } from '../../../modules/local/unifire/updateiprscanwithtaxonomiclineage/main'
include { UNIFIRE_UNIFIRE as UNIFIER_UNIRULE        } from '../../../modules/local/unifire/unifire/main'
include { UNIFIRE_UNIFIRE as UNIFIER_ARBA           } from '../../../modules/local/unifire/unifire/main'
include { UNIFIRE_PIRSR                             } from '../../../modules/local/unifire/pirsr/main'
include { UNIFIRE_UNIFIRE as UNIFIRE_PIRSR_PREDICT  } from '../../../modules/local/unifire/unifire/main'

workflow UNIFIRE {

    take:
    ch_introproscan_xml    // channel: [ val(meta), path(introproscan_xml) ]
    ch_taxadb              // channel: path(taxadb)
    ch_pirsr_data          // channel: path(pirsr_datadir)
    ch_unirule_rules       // channel: path(unirule_urml)
    ch_arba_rules          // channel: path(arba_urml)
    ch_pirsr_rules         // channel: path(pirsr_rules)
    ch_unirule_template    // channel: path(unirule_template)
    ch_arba_template       // channel: path(arba_template)
    ch_pirsr_template      // channel: path(pirsr_template)

    main:

    ch_unirule_out = Channel.empty()
    ch_arba_out = Channel.empty()
    ch_pirsr_out = Channel.empty()
    ch_versions = Channel.empty()

    UNIFIRE_UPDATEIPRSCANWITHTAXONOMICLINEAGE(
        ch_introproscan_xml,
        ch_taxadb
    )

    if (!params.unifire_skip.contains('unirule')) {
        UNIFIER_UNIRULE(
            UNIFIRE_UPDATEIPRSCANWITHTAXONOMICLINEAGE.out.xml,
            ch_unirule_rules,
            ch_unirule_template
        )
        ch_unirule_out = UNIFIER_UNIRULE.out.predictions
        ch_versions = ch_versions.mix(UNIFIER_UNIRULE.out.versions.first())

    }

    if (!params.unifire_skip.contains('arba')) {
        UNIFIER_ARBA(
            UNIFIRE_UPDATEIPRSCANWITHTAXONOMICLINEAGE.out.xml,
            ch_arba_rules,
            ch_arba_template
        )
        ch_arba_out = ch_arba_out.mix(UNIFIER_ARBA.out.predictions)
        ch_versions = ch_versions.mix(UNIFIER_ARBA.out.versions.first())

    }

    if (!params.unifire_skip.contains('pirsr')) {
        // the pirsr annotation is a two step process
        UNIFIRE_PIRSR (
            UNIFIRE_UPDATEIPRSCANWITHTAXONOMICLINEAGE.out.xml,
            ch_pirsr_data
        )
        ch_versions = ch_versions.mix(UNIFIRE_PIRSR.out.versions.first())

        UNIFIRE_PIRSR_PREDICT (
            UNIFIRE_PIRSR.out.fact_xml,
            ch_pirsr_rules,
            ch_pirsr_template
        )
        ch_pirsr_out = ch_pirsr_out.mix(UNIFIRE_PIRSR_PREDICT.out.predictions)
        ch_versions = ch_versions.mix(UNIFIRE_PIRSR_PREDICT.out.versions.first())

    }

    emit:
    unirule_predictions = ch_unirule_out // channel: [ val(meta), [ csv ] ]
    arba_predictions = ch_arba_out       // channel: [ val(meta), [ csv ] ]
    pirsr_predictions = ch_pirsr_out     // channel: [ val(meta), [ csv ] ]
    versions = ch_versions               // channel: [ versions.yml ]
}
