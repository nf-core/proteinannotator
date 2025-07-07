# nf-core/proteinannotator: Output

## Introduction

This document describes the output produced by the pipeline. Most of the plots are taken from the MultiQC report, which summarises results at the end of the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

<!-- TODO nf-core: Write this documentation describing your workflow's output -->

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [Functional Annotation](#functional-annotation) Annotate proteins with functional domains
  - [InterProScan](#Interproscan) - Search the InterPro database for functional domains
  - [Diamond] (#Diamond) - Provide ‘hits’ of potential homologous protein matches between species
- [MultiQC](#multiqc) - Aggregate report describing results and QC from the whole pipeline
- [SeqKit stats](#seqkit_stats) - Simple statistics for protein FASTA files
- [Pipeline information](#pipeline-information) - Report metrics generated during the workflow execution

### Functional Annotation

#### InterProScan

<details markdown="1">
<summary>Output files</summary>

- `functional_annotation/interproscan`
  - `*.gff.gz`: gzip-compressed general feature format (GFF) file
  - `*.json.gz`: gzip-compressed javascript object notation (JSON) file
  - `*.tsv.gz`: gzip-compressed tab-separated variable (TSV) file
  - `*.xml.gz`: gzip-compressed eXtensible markup language (XML) file

</details>

[InterProScan](https://interproscan-docs.readthedocs.io/en/v5/#) is a protein annotation tool that searches [InterPro](http://www.ebi.ac.uk/interpro/), a database which integrates together predictive information about proteins’ function from a number of partner resources, giving an overview of the families that a protein belongs to and the domains and sites it contains.

See also [InterProScan output documentation](https://interproscan-docs.readthedocs.io/en/v5/), where most of these examples are taken from.

##### Generic Feature Format Version 3 (GFF3) Output

The GFF3 format is a flat tab-delimited file, which is much richer then the TSV output format. It allows you to trace back from matches to predicted proteins and to nucleic acid sequences. It also contains a FASTA format representation of the predicted protein sequences and their matches. You will find a documentation of all the columns and attributes used on http://www.sequenceontology.org/gff3.shtml.

<details markdown="1">
<summary>Example InterProScan GFF output</summary>

```
##gff-version 3
##feature-ontology http://song.cvs.sourceforge.net/viewvc/song/ontology/sofa.obo?revision=1.269
##interproscan-version 5.26-65.0
##sequence-region AACH01000027 1 1347
##seqid|source|type|start|end|score|strand|phase|attributes
AACH01000027    provided_by_user    nucleic_acid    1   1347    .   +   .   Name=AACH01000027;md5=b2a7416cb92565c004becb7510f46840;ID=AACH01000027
AACH01000027    getorf  ORF 1   1347    .   +   .   Name=AACH01000027.2_21;Target=pep_AACH01000027_1_1347 1 449;md5=b2a7416cb92565c004becb7510f46840;ID=orf_AACH01000027_1_1347
AACH01000027    getorf  polypeptide 1   449 .   +   .   md5=fd0743a673ac69fb6e5c67a48f264dd5;ID=pep_AACH01000027_1_1347
AACH01000027    Pfam    protein_match   84  314 1.2E-45 +   .   Name=PF00696;signature_desc=Amino acid kinase family;Target=null 84 314;status=T;ID=match$8_84_314;Ontology_term="GO:0008652";date=15-04-2013;Dbxref="InterPro:IPR001048","Reactome:REACT_13"
##sequence-region 2
...
>pep_AACH01000027_1_1347
LVLLAAFDCIDDTKLVKQIIISEIINSLPNIVNDKYGRKVLLYLLSPRDPAHTVREIIEV
LQKGDGNAHSKKDTEIRRREMKYKRIVFKVGTSSLTNEDGSLSRSKVKDITQQLAMLHEA
GHELILVSSGAIAAGFGALGFKKRPTKIADKQASAAVGQGLLLEEYTTNLLLRQIVSAQI
LLTQDDFVDKRRYKNAHQALSVLLNRGAIPIINENDSVVIDELKVGDNDTLSAQVAAMVQ
ADLLVFLTDVDGLYTGNPNSDPRAKRLERIETINREIIDMAGGAGSSNGTGGMLTKIKAA
TIATESGVPVYICSSLKSDSMIEAAEETEDGSYFVAQEKGLRTQKQWLAFYAQSQGSIWV
DKGAAEALSQYGKSLLLSGIVEAEGVFSYGDIVTVFDKESGKSLGKGRVQFGASALEDML
RSQKAKGVLIYRDDWISITPEIQLLFTEF
...
>match$8_84_314
KRIVFKVGTSSLTNEDGSLSRSKVKDITQQLAMLHEAGHELILVSSGAIAAGFGALGFKK
RPTKIADKQASAAVGQGLLLEEYTTNLLLRQIVSAQILLTQDDFVDKRRYKNAHQALSVL
LNRGAIPIINENDSVVIDELKVGDNDTLSAQVAAMVQADLLVFLTDVDGLYTGNPNSDPR
AKRLERIETINREIIDMAGGAGSSNGTGGMLTKIKAATIATESGVPVYICS
```

</details>

##### JavaScript Object Notation (JSON) Output

JSON representation of the matches - an alternative to XML format. As new releases are made public, the changes to the expected JSON format are documented in [Change log for InterProScan JSON output format](https://interproscan-docs.readthedocs.io/en/v5/JSONOutputFormatHistory.html#change-log-for-interproscan-json-output-format).

<details markdown="1">
<summary>Example InterProScan JSON output</summary>

```
{
 "interproscan-version": "5.26-65.0",
"results": [{
  "sequence" : "MSKIGKSIRLERIIDRKTRKTVIVPMDHGLTVGPIPGLIDLAAAVDKVAEGGANAVLGHMGLPLYGHRGYGKDVGLIIHLSASTSLGPDANHKVLVTRVEDAIRVGADGVSIHVNVGAEDEAEMLRDLGMVARRCDLWGMPLLAMMYPRGAKVRSEHSVEYVKHAARVGAELGVDIVKTNYTGSPETFREVVRGCPAPVVIAGGPKMDTEADLLQMVYDAMQAGAAGISIGRNIFQAENPTLLTRKLSKIVHEGYTPEEAARLKL",
  "md5" : "88d47cc807fe8e977130b0cc93e0bd61",
  "matches" : [ {
    "signature" : {
      "accession" : "PIRSF038992",
      "name" : "Aldolase_Ia",
      "description" : null,
      "type" : null,
      "signatureLibraryRelease" : {
        "library" : "PIRSF",
        "version" : "3.01"
      },
      "models" : {
        "PIRSF038992" : {
          "accession" : "PIRSF038992",
          "name" : "Aldolase_Ia",
          "description" : null,
          "key" : "PIRSF038992"
        }
      },
      "entry" : {
        "accession" : "IPR002915",
        "name" : "DeoC/FbaB/lacD_aldolase",
        "description" : "DeoC/FbaB/ lacD aldolase",
        "type" : "FAMILY",
        "goXRefs" : [ {
          "identifier" : "GO:0016829",
          "name" : "lyase activity",
          "databaseName" : "GO",
          "category" : "MOLECULAR_FUNCTION"
        } ],
        "pathwayXRefs" : [ {
          "identifier" : "R-HSA-71336",
          "name" : "Pentose phosphate pathway (hexose monophosphate shunt)",
          "databaseName" : "Reactome"
        }, {
          "identifier" : "R-HSA-6798695",
          "name" : "Neutrophil degranulation",
          "databaseName" : "Reactome"
        } ]
      }
    },
    "locations" : [ {
      "start" : 1,
      "end" : 265,
      "hmmStart" : 2,
      "hmmEnd" : 262,
      "hmmBounds" : "INCOMPLETE",
      "evalue" : 3.3E-94,
      "score" : 302.6,
      "envelopeStart" : 1,
      "envelopeEnd" : 265
    } ],
    "evalue" : 3.0E-94,
    "score" : 302.7
  }, {
    ...
}]
}
```

</details>

##### Tab-separated values format (TSV) Output

TSV: Basic tab delimited format. Outputs only those sequences with domain matches.

<details markdown="1">
<summary>Example InterProScan TSV output</summary>

```
P51587  14086411a2cdf1c4cba63020e1622579    3418    Pfam    PF09103 BRCA2, oligonucleotide/oligosaccharide-binding, domain 1    2670    2799    7.9E-43 T   15-03-2013
P51587  14086411a2cdf1c4cba63020e1622579    3418    ProSiteProfiles PS50138 BRCA2 repeat profile.   1002    1036    0.0 T   18-03-2013  IPR002093   BRCA2 repeat    GO:0005515|GO:0006302
P51587  14086411a2cdf1c4cba63020e1622579    3418    Gene3D  G3DSA:2.40.50.140       2966    3051    3.1E-52 T   15-03-2013
...
```

The TSV format presents the match data in columns as follows:

1. Protein accession (e.g. P51587)
2. Sequence MD5 digest (e.g. 14086411a2cdf1c4cba63020e1622579)
3. Sequence length (e.g. 3418)
4. Analysis (e.g. Pfam / PRINTS / Gene3D)
5. Signature accession (e.g. PF09103 / G3DSA:2.40.50.140)
6. Signature description (e.g. BRCA2 repeat profile)
7. Start location
8. Stop location
9. Score - is the e-value (or score) of the match reported by member database method (e.g. 3.1E-52)
10. Status - is the status of the match (T: true)
11. Date - is the date of the run
12. InterPro annotations - accession (e.g. IPR002093)
13. InterPro annotations - description (e.g. BRCA2 repeat)
14. GO annotations with their source(s), e.g. GO:0005515(InterPro)|GO:0006302(PANTHER)|GO:0007195(InterPro,PANTHER). This is an optional column; only displayed if the `--goterms` option is switched on
15. Pathways annotations, e.g. REACT_71. This is an optional column; only displayed if the `--pathways` option is switched on

If a value is missing in a column, for example, the match has no InterPro annotation, a ‘-‘ is displayed.

</details>

##### Extensible Markup Language (XML) Output

XML representation of the matches - this is the richest form of the data. The XML Schema Definition (XSD) file links are below the example output.

The XML Schema Definition (XSD) is available [here](http://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/schemas/).

<details markdown="1">
<summary>Example InterProScan XML output</summary>

```
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<protein-matches xmlns="http://www.ebi.ac.uk/interpro/resources/schemas/interproscan5" interproscan-version="5.26-65.0">
    <protein>
        <sequence md5="14086411a2cdf1c4cba63020e1622579">MPIGSKERPTFFEIFKTRCNKADLGPISLNWFEELSSEAPPYNSEPAEESEHKNNNYEPNLFKTPQRKPSYNQLASTPIIFKEQGLTLPLYQSPVKELDKFKLDLGRNVPNSRHKSLRTVKTKMDQADDVSCPLLNSCLSESPVVLQCTHVTPQRDKSVVCGSLFHTPKFVKGRQTPKHISESLGAEVDPDMSWSSSLATPPTLSSTVLIVRNEEASETVFPHDTTANVKSYFSNHDESLKKNDRFIASVTDSENTNQREAASHGFGKTSGNSFKVNSCKDHIGKSMPNVLEDEVYETVVDTSEEDSFSLCFSKCRTKNLQKVRTSKTRKKIFHEANADECEKSKNQVKEKYSFVSEVEPNDTDPLDSNVAHQKPFESGSDKISKEVVPSLACEWSQLTLSGLNGAQMEKIPLLHISSCDQNISEKDLLDTENKRKKDFLTSENSLPRISSLPKSEKPLNEETVVNKRDEEQHLESHTDCILAVKQAISGTSPVASSFQGIKKSIFRIRESPKETFNASFSGHMTDPNFKKETEASESGLEIHTVCSQKEDSLCPNLIDNGSWPATTTQNSVALKNAGLISTLKKKTNKFIYAIHDETSYKGKKIPKDQKSELINCSAQFEANAFEAPLTFANADSGLLHSSVKRSCSQNDSEEPTLSLTSSFGTILRKCSRNETCSNNTVISQDLDYKEAKCNKEKLQLFITPEADSLSCLQEGQCENDPKSKKVSDIKEEVLAAACHPVQHSKVEYSDTDFQSQKSLLYDHENASTLILTPTSKDVLSNLVMISRGKESYKMSDKLKGNNYESDVELTKNIPMEKNQDVCALNENYKNVELLPPEKYMRVASPSRKVQFNQNTNLRVIQKNQEETTSISKITVNPDSEELFSDNENNFVFQVANERNNLALGNTKELHETDLTCVNEPIFKNSTMVLYGDTGDKQATQVSIKKDLVYVLAEENKNSVKQHIKMTLGQDLKSDISLNIDKIPEKNNDYMNKWAGLLGPISNHSFGGSFRTASNKEIKLSEHNIKKSKMFFKDIEEQYPTSLACVEIVNTLALDNQKKLSKPQSINTVSAHLQSSVVVSDCKNSHITPQMLFSKQDFNSNHNLTPSQKAEITELSTILEESGSQFEFTQFRKPSYILQKSTFEVPENQMTILKTTSEECRDADLHVIMNAPSIGQVDSSKQFEGTVEIKRKFAGLLKNDCNKSASGYLTDENEVGFRGFYSAHGTKLNVSTEALQKAVKLFSDIENISEETSAEVHPISLSSSKCHDSVVSMFKIENHNDKTVSEKNNKCQLILQNNIEMTTGTFVEEITENYKRNTENEDNKYTAASRNSHNLEFDGSDSSKNDTVCIHKDETDLLFTDQHNICLKLSGQFMKEGNTQIKEDLSDLTFLEVAKAQEACHGNTSNKEQLTATKTEQNIKDFETSDTFFQTASGKNISVAKESFNKIVNFFDQKPEELHNFSLNSELHSDIRKNKMDILSYEETDIVKHKILKESVPVGTGNQLVTFQGQPERDEKIKEPTLLGFHTASGKKVKIAKESLDKVKNLFDEKEQGTSEITSFSHQWAKTLKYREACKDLELACETIEITAAPKCKEMQNSLNNDKNLVSIETVVPPKLLSDNLCRQTENLKTSKSIFLKVKVHENVEKETAKSPATCYTNQSPYSVIENSALAFYTSCSRKTSVSQTSLLEAKKWLREGIFDGQPERINTADYVGNYLYENNSNSTIAENDKNHLSEKQDTYLSNSSMSNSYSYHSDEVYNDSGYLSKNKLDSGIEPVLKNVEDQKNTSFSKVISNVKDANAYPQTVNEDICVEELVTSSSPCKNKNAAIKLSISNSNNFEVGPPAFRIASGKIVCVSHETIKKVKDIFTDSFSKVIKENNENKSKICQTKIMAGCYEALDDSEDILHNSLDNDECSTHSHKVFADIQSEEILQHNQNMSGLEKVSKISPCDVSLETSDICKCSIGKLHKSVSSANTCGIFSTASGKSVQVSDASLQNARQVFSEIEDSTKQVFSKVLFKSNEHSDQLTREENTAIRTPEHLISQKGFSYNVVNSSAFSGFSTASGKQVSILESSLHKVKGVLEEFDLIRTEHSLHYSPTSRQNVSKILPRVDKRNPEHCVNSEMEKTCSKEFKLSNNLNVEGGSSENNHSIKVSPYLSQFQQDKQQLVLGTKVSLVENIHVLGKEQASPKNVKMEIGKTETFSDVPVKTNIEVCSTYSKDSENYFETEAVEIAKAFMEDDELTDSKLPSHATHSLFTCPENEEMVLSNSRIGKRRGEPLILVGEPSIKRNLLNEFDRIIENQEKSLKASKSTPDGTIKDRRLFMHHVSLEPITCVPFRTTKERQEIQNPNFTAPGQEFLSKSHLYEHLTLEKSSSNLAVSGHPFYQVSATRNEKMRHLITTGRPTKVFVPPFKTKSHFHRVEQCVRNINLEENRQKQNIDGHGSDDSKNKINDNEIHQFNKNNSNQAAAVTFTKCEEEPLDLITSLQNARDIQDMRIKKKQRQRVFPQPGSLYLAKTSTLPRISLKAAVGGQVPSACSHKQLYTYGVSKHCIKINSKNAESFQFHTEDYFGKESLWTGKGIQLADGGWLIPSNDGKAGKEEFYRALCDTPGVDPKLISRIWVYNHYRWIIWKLAAMECAFPKEFANRCLSPERVLLQLKYRYDTEIDRSRRSAIKKIMERDDTAAKTLVLCVSDIISLSANISETSSNKTSSADTQKVAIIELTDGWYAVKAQLDPPLLAVLKNGRLTVGQKIILHGAELVGSPDACTPLEAPESLMLKISANSTRPARWYTKLGFFPDPRPFPLPLSSLFSDGGNVGCVDVIIQRAYPIQWMEKTSSGLYIFRNEREEEKEAAKYVEAQQKRLEALFTKIQEEFEEHEENTTKPYLPSRALTRQQVRALQDGAELYEAVKNAADPAYLEGYFSEEQLRALNNHRQMLNDKKQAQIQLEIRKAMESAEQKEQGLSRDVTTVWKLRIVSYSKKEKDSVILSIWRPSSDLYSLLTEGKRYRIYHLATSKSKSKSERANIQLAATKKTQYQQLPVSDEILFQIYQPREPLHFSKFLDPDFQPSCSEVDLIGFVVSVVKKTGLAPFVYLSDECYNLLAIKFWIDLNEDIIKPHMLIAASNLQWRPESKSGLLTLFAGDFSVFSASPKEGHFQETFNKMKNTVENIDILCNEAENKLMHILHANDPKWSTPTKDCTSGPYTAQIIPGTGNKLLMSSPNCEIYYQSPLSLCMAKRKSVSTPVSAQMTSKSCKGEKEIDDQKNCKKRRALDFLSRLPLPPPVSPICTFVSPAAQKAFQPPRSCGTKYETPIKKKELNSPQMTPFKKFNEISLLESNSIADEELALINTQALLSGSTGEKQFISVSESTRTAPTSSEDYLRLKRRCTTSLIKEQESSQASTEECEKNKQDTITTKKYI</sequence>
        <xref id="P51587"/>
        <matches>
...
            <hmmer3-match score="341.9" evalue="0.0">
                <signature name="BRCA-2_helical" desc="BRCA2, helical" ac="PF09169">
                    <entry type="DOMAIN" name="BRCA2_hlx" desc="Breast cancer type 2 susceptibility protein, helical domain" ac="IPR015252">
                        <go-xref category="BIOLOGICAL_PROCESS" name="double-strand break repair via homologous recombination" id="GO:0000724" db="GO"/>
                        <go-xref category="MOLECULAR_FUNCTION" name="single-stranded DNA binding" id="GO:0003697" db="GO"/>
                        <go-xref category="BIOLOGICAL_PROCESS" name="DNA recombination" id="GO:0006310" db="GO"/>
                    </entry>
                    <models>
                        <model name="BRCA-2_helical" desc="BRCA2, helical" ac="PF09169"/>
                    </models>
                    <signature-library-release version="27.0" library="PFAM"/>
                </signature>
                <locations>
                    <hmmer3-location env-start="2479" env-end="2667" hmm-end="195" hmm-start="1" evalue="9.6E-102" score="0.0" end="2667" start="2479"/>
                </locations>
            </hmmer3-match>
...
            <superfamilyhmmer3-match evalue="0.0">
                <signature name="BRCA2 helical domain" ac="SSF81872">
                    <entry type="DOMAIN" name="BRCA2_hlx" desc="Breast cancer type 2 susceptibility protein, helical domain" ac="IPR015252">
                        <go-xref category="BIOLOGICAL_PROCESS" name="double-strand break repair via homologous recombination" id="GO:0000724" db="GO"/>
                        <go-xref category="MOLECULAR_FUNCTION" name="single-stranded DNA binding" id="GO:0003697" db="GO"/>
                        <go-xref category="BIOLOGICAL_PROCESS" name="DNA recombination" id="GO:0006310" db="GO"/>
                    </entry>
                    <models>
                        <model name="BRCA2 helical domain" ac="0039279"/>
                        <model name="BRCA2 helical domain" ac="0040951"/>
                    </models>
                    <signature-library-release version="1.75" library="SUPERFAMILY"/>
                </signature>
                <locations>
                    <superfamilyhmmer3-location end="2668" start="2479"/>
                </locations>
            </superfamilyhmmer3-match>
...
            <rpsblast-match>
                <signature ac="cd08964" desc="L-asparaginase_II" name="L-asparaginase_II">
                    <models>
                        <model ac="cd08964" desc="L-asparaginase_II" name="L-asparaginase_II"/>
                    </models>
                    <signature-library-release library="CDD" version="3.14"/>
                </signature>
                <locations>
                    <rpsblast-location evalue="8.66035E-152" score="433.09" start="50" end="364">
                        <sites>
                            <rpsblast-site description="homotetramer interface" numLocations="51">
<site-locations>
    <site-location residue="Y" start="271" end="271"/>
    <site-location residue="R" start="246" end="246"/>
    <site-location residue="Y" start="229" end="229"/>
    ...
</site-locations>
                            </rpsblast-site>
                            ...
                        </sites>
                    </rpsblast-location>
                </locations>
            </rpsblast-match>
            ...
        </matches>
    </protein>
</protein-matches>
```

</details>

#### Diamond

<details markdown="1">
<summary>Output files</summary>

- `functional_annotation/diamond`
  - `*.blast`: (Basic Local Alignment Search Tool) BLAST pairwise format
  - `*.xml`: BLAST Extensible Markup Language (XML) format
  - `*.txt`: BLAST tabular format (default). This format can be customized, the 6 may be followed by a space-separated list of the blast_columns keywords, each specifying a field of the output. 
  - `*.daa`: DIAMOND alignment archive (DAA). The DAA format is a proprietary binary format that can subsequently be used to generate other output formats using the view command. It is also supported by MEGAN and allows a quick import of results. 
  - `*.sam`: SAM format. 
  - `*.tsv`: Taxonomic classification. This format will not print alignments but only a taxonomic classification for each query using the LCA algorithm. 
  - `*.paf`: PAF format. The custom fields in the format are AS (bit score), ZR (raw score) and ZE (e-value)

</details>

[Diamond](https://github.com/bbuchfink/diamond) provides sensitive protein sequence alignment. The process provides ‘hits’ that are potential homologous protein matches between species, indicating a evolutionary relationship, derived by protein sequence similarity.

##### Pairwise Alignment Format (.blast) Output

The pairwise BLAST format is a human readable format that is useful for visual inspection, if one desires to get full alignment details for individual alignments.

<details markdown="1">
<summary>Example Pairwise Alignment Format output</summary>

```

```

</details>

##### BLAST Extensible Markup Language (XML) Output

XML (Extensible Markup Language) file has the same information as the pairwise file but is suited for bioinformatics software and scripts (machine readable), due to it’s structure and parsing of data.

<details markdown="1">
<summary>Example Extensible Markup Language (XML) output</summary>

```

```

</details>

##### Text File (TXT) Output --default

The BLAST tabular format is the default output and the output columns can be modified depending on analysis needs. This format is much smaller than the other BLAST formats and compatible with most all forward processing and is easily filtered and analyzed.

<details markdown="1">
<summary>Example Text File (TXT) output</summary>

```

```

</details>

##### DIAMOND Alignment Archive (DAA) Output

DIAMOND alignment archive (DAA) is a compressed proprietary binary format that is can be converted to any of the other output formats (.blast, .xml, .txt, .sam, .tsv, .paf) with the DIAMOND view command without rerunning the pipeline. It can also be used in some meta-genomic analysis software. 

<details markdown="1">
<summary>Example DIAMOND Alignment Archive (DAA) output</summary>

```

```

</details>

##### Sequence Alignment/Map (SAM) Output

The SAM (Sequence Alignment/Map) file adapts the DIAMOND protein alignment output in a similar fashion to the genomic alignment. This allows for easy integration into SAM/BAM pipelines and protein alignment visualization with IGV browser.

<details markdown="1">
<summary>Example Sequence Alignment/Map (SAM) output</summary>

```

```

</details>

##### Tab-Separated Values (TSV) Output

The taxonomic classification (.tsv) output provides taxonomic composition and is useful for biological interpretation rather than alignment comparison.

<details markdown="1">
<summary>Example Tab-Separated Values (TSV) output</summary>

```

```

</details>

##### Pairwise Mapping Format (PAF)

The PAF (Pairwise mApping Format) file that is originally used for long read sequencing. DIAMOND adds three additional variables, AS (bit score), ZR (raw alignment score), and ZE (E-value), to provide statistical evidence for protein alignment. This format is useful if one is looking for positional information and statistical significance. 

<details markdown="1">
<summary>Example InterProScan GFF output</summary>

```

```

</details>

### MultiQC

<details markdown="1">
<summary>Output files</summary>

- `multiqc/`
  - `multiqc_report.html`: a standalone HTML file that can be viewed in your web browser.
  - `multiqc_data/`: directory containing parsed statistics from the different tools used in the pipeline.
  - `multiqc_plots/`: directory containing static images from the report in various formats.

</details>

[MultiQC](http://multiqc.info) is a visualization tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in the report data directory.

Results generated by MultiQC collate pipeline QC from supported tools e.g. FastQC. The pipeline has special steps which also allow the software versions to be reported in the MultiQC output for future traceability. For more information about how to use MultiQC reports, see <http://multiqc.info>.

### SeqKit stats

<details markdown="1">
<summary>Output files</summary>

- `seqkit/`
  - `{prefix}.tsv`: output of `seqkit stats` command on `{prefix}.fasta` input file, in tab-delimited text format.

</details>

[SeqKit stats](https://bioinf.shenwei.me/seqkit/usage/#stats) generates simple statistics for protein FASTA files, such as number of residues, minimal sequence length, average sequence length, and maximal sequence length.

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.
  - Parameters used by the pipeline run: `params.json`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
