# Changelog

## [0.4.2](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.4.1...v0.4.2) (2026-10-04)


### Documentation

* clean code fence formatting and expand complete devsecops runbook ([#38](https://github.com/jason-victor1/devsecops-master-repo/issues/38)) ([af80487](https://github.com/jason-victor1/devsecops-master-repo/commit/af80487a6faa9362ddd8ad199e91f966b87347f6))

## [0.4.1](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.4.0...v0.4.1) (2026-10-03)


### Documentation

* add comprehensive DevSecOps architecture and verification runbook ([#36](https://github.com/jason-victor1/devsecops-master-repo/issues/36)) ([db5a640](https://github.com/jason-victor1/devsecops-master-repo/commit/db5a640a4d839de48e437701f5cc82c8dca1a218))

## [0.4.0](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.3.0...v0.4.0) (2026-10-03)


### Features

* **terraform:** add EKS Pod Identity module and production Kyverno policy ([#34](https://github.com/jason-victor1/devsecops-master-repo/issues/34)) ([f60d7db](https://github.com/jason-victor1/devsecops-master-repo/commit/f60d7db48ce9e42d40ceb981428b32d10f2ca400))

## [0.3.0](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.2.0...v0.3.0) (2026-10-03)


### Features

* **ci:** add Syft CycloneDX SBOM and Cosign keyless artifact signing ([#31](https://github.com/jason-victor1/devsecops-master-repo/issues/31)) ([8150ef6](https://github.com/jason-victor1/devsecops-master-repo/commit/8150ef636cf80bc1fac36f0bcdec5233999ee42c))
* **k8s:** add Kyverno image signature verification cluster policy ([#32](https://github.com/jason-victor1/devsecops-master-repo/issues/32)) ([21007f4](https://github.com/jason-victor1/devsecops-master-repo/commit/21007f40fd0929bafdf0a236c86ba34e07546f82))


### Bug Fixes

* **docker:** patch base OS packages in runtime stage to eliminate HIGH CVEs ([#29](https://github.com/jason-victor1/devsecops-master-repo/issues/29)) ([abd425d](https://github.com/jason-victor1/devsecops-master-repo/commit/abd425d2c0208f59f8ed1c5f2861d1f15c7c8dad))

## [0.2.0](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.1.3...v0.2.0) (2026-10-03)


### Features

* **ci:** add keyless AWS OIDC authentication and ECR container push ([#27](https://github.com/jason-victor1/devsecops-master-repo/issues/27)) ([d424d4d](https://github.com/jason-victor1/devsecops-master-repo/commit/d424d4d010b2eb66a0ef67b95ff8c0b8865bbaea))

## [0.1.3](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.1.2...v0.1.3) (2026-09-11)


### Bug Fixes

* **k8s:** enforce runtime default seccomp profile and resource limits ([#21](https://github.com/jason-victor1/devsecops-master-repo/issues/21)) ([fa074ab](https://github.com/jason-victor1/devsecops-master-repo/commit/fa074ab34f15705d2ebafa729d8a994d1ab75066))
* **k8s:** specify explicit namespace and pin container image tag ([#19](https://github.com/jason-victor1/devsecops-master-repo/issues/19)) ([219dd02](https://github.com/jason-victor1/devsecops-master-repo/commit/219dd02eaf031d4588f762bbee0b75b225409cc5))

## [0.1.2](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.1.1...v0.1.2) (2026-09-04)


### Documentation

* expand repository layout to reflect complete tree ([#16](https://github.com/jason-victor1/devsecops-master-repo/issues/16)) ([d4d72d6](https://github.com/jason-victor1/devsecops-master-repo/commit/d4d72d6d7de71eb868ad1b1b7e7ec2f769a8da6d))
* update readme with verified security matrix and architecture ([#14](https://github.com/jason-victor1/devsecops-master-repo/issues/14)) ([fd1c9b2](https://github.com/jason-victor1/devsecops-master-repo/commit/fd1c9b2d3f75a98c7d475bf89816d069596f9fda))

## [0.1.1](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.1.0...v0.1.1) (2026-09-04)


### Documentation

* add production security validation compliance record ([#12](https://github.com/jason-victor1/devsecops-master-repo/issues/12)) ([08065ba](https://github.com/jason-victor1/devsecops-master-repo/commit/08065ba43a21e4f919ab68666de9f46aaee854a8))

## 0.1.0 (2026-09-04)


### Features

* **api:** add telemetry metadata schema annotations ([#5](https://github.com/jason-victor1/devsecops-master-repo/issues/5)) ([282e45b](https://github.com/jason-victor1/devsecops-master-repo/commit/282e45b3b23f958d098276a4487b3f24ab086bc6))
* initial devsecops repository scaffolding ([96ee1f0](https://github.com/jason-victor1/devsecops-master-repo/commit/96ee1f05c297b5a130b79fb1d6a4bc342d7ccc9a))


### Bug Fixes

* **ci:** decouple ecr push and run local container scan ([#9](https://github.com/jason-victor1/devsecops-master-repo/issues/9)) ([37b5cd6](https://github.com/jason-victor1/devsecops-master-repo/commit/37b5cd6c41cb1264893495d83ffb8180f1cf64f3))
* **docker:** remove brittle debian patch version pins in dockerfile ([#11](https://github.com/jason-victor1/devsecops-master-repo/issues/11)) ([e9e196d](https://github.com/jason-victor1/devsecops-master-repo/commit/e9e196dddf4cf08de44d9d88eb33d3934716ebaa))
* **tests:** resolve ruff linting and import sorting violations ([#7](https://github.com/jason-victor1/devsecops-master-repo/issues/7)) ([7a7cd53](https://github.com/jason-victor1/devsecops-master-repo/commit/7a7cd5338f71d7ed1834fccf396f1544940feace))
