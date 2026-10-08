# Changelog

## [0.8.0](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.7.1...v0.8.0) (2026-10-08)


### Features

* **security:** enforce kyverno cosign sbom attestation and imds egress isolation ([#69](https://github.com/jason-victor1/devsecops-master-repo/issues/69)) ([5870dcc](https://github.com/jason-victor1/devsecops-master-repo/commit/5870dcc41c42366c3e5f57d9a647754c7f3cc829))

## [0.7.1](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.7.0...v0.7.1) (2026-10-07)


### Documentation

* **adr:** add architecture decision records 0001-0003 and empirical validation ledger ([#67](https://github.com/jason-victor1/devsecops-master-repo/issues/67)) ([8f7167b](https://github.com/jason-victor1/devsecops-master-repo/commit/8f7167b58fa8251035a3a6943ae037c8fad7cb5d))

## [0.7.0](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.6.3...v0.7.0) (2026-10-07)


### Features

* **ssm:** add zero-trust private bastion module and ssm tunneling script ([#64](https://github.com/jason-victor1/devsecops-master-repo/issues/64)) ([e447f6d](https://github.com/jason-victor1/devsecops-master-repo/commit/e447f6d8225d8cdcfcc77c2fd4fc4656468b5e84))


### Documentation

* enrich README with architecture diagram, zero-trust ssm guide, and verification proof ([#66](https://github.com/jason-victor1/devsecops-master-repo/issues/66)) ([8969093](https://github.com/jason-victor1/devsecops-master-repo/commit/8969093cc12345c30ad08ec474a09cc245a19765))

## [0.6.3](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.6.2...v0.6.3) (2026-10-07)


### Bug Fixes

* **eks:** enforce private-only cluster endpoint access for prod ([#63](https://github.com/jason-victor1/devsecops-master-repo/issues/63)) ([aec3196](https://github.com/jason-victor1/devsecops-master-repo/commit/aec3196c2d53ef65176a03f5096fad175d341f7b))
* **eks:** set zero-trust module defaults and restrict prod api endpoint cidr ([#61](https://github.com/jason-victor1/devsecops-master-repo/issues/61)) ([15b59a7](https://github.com/jason-victor1/devsecops-master-repo/commit/15b59a7e7ae29ee683bfd4d627ad110698ece109))

## [0.6.2](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.6.1...v0.6.2) (2026-10-07)


### Bug Fixes

* **falco:** adjust sa token rule for projected paths and whitelist kyverno ([#59](https://github.com/jason-victor1/devsecops-master-repo/issues/59)) ([8b482bc](https://github.com/jason-victor1/devsecops-master-repo/commit/8b482bc873c8d15efdd4e72a635968babb663c3f))

## [0.6.1](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.6.0...v0.6.1) (2026-10-07)


### Bug Fixes

* **falco:** pin falcosidekick to 2.31.1 for AWS SDK v1 IRSA compatibility ([#58](https://github.com/jason-victor1/devsecops-master-repo/issues/58)) ([d01b1e7](https://github.com/jason-victor1/devsecops-master-repo/commit/d01b1e72779c26e84669abda5b45be8746baaa96))
* **infra:** add AutoScaling EBS KMS permissions and expose public endpoint controls ([#53](https://github.com/jason-victor1/devsecops-master-repo/issues/53)) ([f11d61d](https://github.com/jason-victor1/devsecops-master-repo/commit/f11d61d52558417e3590c34217a047f048839608))

## [0.6.0](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.5.0...v0.6.0) (2026-10-04)


### Features

* **k8s:** add production Helm values and Kyverno verification policy for Phase 2 ([#48](https://github.com/jason-victor1/devsecops-master-repo/issues/48)) ([a29d47f](https://github.com/jason-victor1/devsecops-master-repo/commit/a29d47f2489538b90774af50daf07f2d0aa7fd00))

## [0.5.0](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.4.4...v0.5.0) (2026-10-04)


### Features

* **infra:** add EKS 1.31, multi-AZ VPC, and Pod Identity modules for Phase 2 ([#46](https://github.com/jason-victor1/devsecops-master-repo/issues/46)) ([c9ac792](https://github.com/jason-victor1/devsecops-master-repo/commit/c9ac792698d40ef96e478a03d187a04198ba660f))

## [0.4.4](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.4.3...v0.4.4) (2026-10-04)


### Documentation

* add system design architecture and threat model specification ([#44](https://github.com/jason-victor1/devsecops-master-repo/issues/44)) ([5d62a88](https://github.com/jason-victor1/devsecops-master-repo/commit/5d62a882703d1e99990b3adeee429868fd6a3834))

## [0.4.3](https://github.com/jason-victor1/devsecops-master-repo/compare/v0.4.2...v0.4.3) (2026-10-04)


### Bug Fixes

* **ci:** gate ECR build-and-push job to main branch pushes ([#42](https://github.com/jason-victor1/devsecops-master-repo/issues/42)) ([902a38e](https://github.com/jason-victor1/devsecops-master-repo/commit/902a38e6a1ad077afb2c13aa1d0e0e0abd1e7798))

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
