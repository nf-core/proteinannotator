# nf-core/proteinannotator: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.0.0dev - [date]

Initial release of nf-core/proteinannotator, created with the [nf-core](https://nf-co.re/) template.

### `Added`

- [[PR #42](https://github.com/nf-core/proteinannotator/pull/42)] Updated to `nf-test` on GitHub Actions and in the `PULL_REQUEST_TEMPLATE.md`
- [[PR #13](https://github.com/nf-core/proteinannotator/pull/13)] Add nf-core seqkit/stats module

- [[PR #45]](https://github.com/nf-core/proteinannotator/pull/45) Add the Unifire modules and subworkflow. Note that the docker
  image is served from a personal repository,
  the pirsr call in the unifire workflow does not work due to a bug in a dependency of the
  unifire software (it is skipped via a parameter), and the update lineage script
  had to be slightly modified and placed in a
  template due to a typo in the original script. The unifire maintainers are aware, but
  in the meantime, this workflow can be used.

### `Fixed`

### `Dependencies`

### `Deprecated`
