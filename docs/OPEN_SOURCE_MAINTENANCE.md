# Open Source Maintenance

This document summarizes the public maintenance model for `GlobeScholar`.

## Project scope

`GlobeScholar` is a SwiftUI iOS app plus serverless Python data pipeline for discovering and tracking global academic opportunities such as summer research programs and PhD openings. The app uses MapKit and SwiftData, while the backend pipeline uses GitHub Actions and AI-assisted cleanup to convert unstructured sources into structured opportunity records.

The repository is intended to be useful for:

- students tracking global academic opportunities in one mobile interface
- developers building small iOS apps backed by a serverless data-refresh pipeline
- maintainers experimenting with structured extraction from unstructured public sources

## Maintainer responsibilities

The primary maintainer is responsible for:

- reviewing changes to the SwiftUI app, local data model, scraper, JSON schema, and GitHub Actions workflow
- triaging issues about data quality, source attribution, syncing behavior, and calendar permissions
- keeping API keys, personal data, Apple signing material, and private scraped data out of version control
- documenting source limitations, schema changes, and safe sample data
- cutting releases when the app baseline, data schema, or automation workflow changes materially

## Current maintenance priorities

1. Stabilize the opportunity JSON schema and document the data contract.
2. Improve scraper validation, source attribution, and duplicate handling.
3. Add app-level screenshots, example records, and setup troubleshooting.
4. Add small issues for iOS polish, backend tests, and documentation tasks.
5. Keep all secrets in GitHub Actions or local environment variables.

## API-credit use boundary

If external AI/API credits are used, they should support open-source data extraction and maintenance: schema validation, structured cleanup, summarization, deduplication, test-case generation, and documentation. They should not expose private user data or operate as a public paid API proxy.
