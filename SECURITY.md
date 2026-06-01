# Security Policy

## Supported scope

Security reports are accepted for the current `main` branch.

## Reporting a vulnerability

Please do not open public issues for vulnerabilities, leaked secrets, private user data, API keys, Apple signing material, or calendar data. Contact the maintainer through the GitHub profile or use GitHub's private vulnerability reporting flow if it is enabled for this repository.

When reporting, include:

- Affected app, scraper, or workflow
- Reproduction steps
- Expected and actual behavior
- Whether credentials or personal data may be exposed

## Data and secret handling

API keys belong in GitHub Actions secrets or local environment variables. The repository should only contain redistributable source code, documentation, schemas, and safe sample data.
