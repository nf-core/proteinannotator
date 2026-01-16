# nf-core/proteinannotator: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0dev - [date]

Initial release of nf-core/proteinannotator, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- [#65](https://github.com/nf-core/proteinannotator/pull/65) - Converted the pipeline schematic to nf-core metromap. (by @vagkaratzas)
- [#62](https://github.com/nf-core/proteinannotator/pull/62) - Added the option to download and use the latest FunFam HMM library (or use path to an existing one) for domain annotation. (by @vagkaratzas)
- [#61](https://github.com/nf-core/proteinannotator/pull/61) - Added nf-core modules `ARIA2` and `HMMER_HMMSEARCH` to download latest Pfam HMM library (or use path to existing one) and match domains to input sequences. (by @vagkaratzas)
- [#60](https://github.com/nf-core/proteinannotator/pull/60) - Added nf-core module `S4PRED_RUNMODEL` for secondary structure prediction (i.e., α-helix, a β-strand or a coil). (by @vagkaratzas)
- [#59](https://github.com/nf-core/proteinannotator/pull/59) - Added nf-core qc and pre-processing subworkflow for amino acid sequences `FAA_SEQFU_SEQKIT`. (by @vagkaratzas)
- [#57](https://github.com/nf-core/proteinannotator/pull/57) - nf-core tools template update to 3.5.1. (by @vagkaratzas)
- [#52](https://github.com/nf-core/proteinannotator/pull/52) - Add option to turn off InterProScan for testing
- [#51](https://github.com/nf-core/proteinannotator/pull/51) - Update to nf-core/tools v3.3.1
- [#47](https://github.com/nf-core/proteinannotator/pull/47) - Update metromap with more tools added from [May 2025 Hackathon](https://nf-co.re/events/2025/hackathon-boston)
<!-- - [#43](https://github.com/nf-core/proteinannotator/pull/44) - Add [mTM-Align](https://nf-co.re/modules/mtmalign_align/) and [MMseqs2 Search](https://nf-co.re/modules/mmseqs_search/) modules -->
- [#42](https://github.com/nf-core/proteinannotator/pull/42) - Updated to `nf-test` on GitHub Actions and in the `PULL_REQUEST_TEMPLATE.md`
- [#13](https://github.com/nf-core/proteinannotator/pull/13) - Add nf-core seqkit/stats module
- [#9](https://github.com/nf-core/proteinannotator/pull/9) - Add [InterProScan](https://interproscan-docs.readthedocs.io/) module

### `Fixed`

### `Dependencies`

### `Deprecated`
