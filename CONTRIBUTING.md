# Contributing to the Enterprise Repository

## Commit Standards

1. **Cryptographic Signing Required**: All commits must be signed with an authorized `ED25519` SSH or GPG key. Unsigned commits are rejected by GitHub Rulesets.
2. **Conventional Commits**: Format commit messages strictly:
   - `feat(scope): add telemetry ingestion filter`
   - `fix(auth): correct token validation check`
   - `chore(deps): bump fastapi to 0.115.8`

## Development Workflow

1. Clone the repository and install hooks:

   ```bash
   pre-commit install
   ```

2. Create your feature branch (`feat/ingestion-enhancement`).
3. Validate tests and coverage locally:

   ```bash
   pytest --cov=src/app src/tests/
   ```

4. Push and open a Pull Request adhering to `.github/pull_request_template.md`.
