# Contributing

Thanks for helping improve this project.

## How to contribute

1. Open an issue before starting a large change to the iOS app, scraper, or data schema.
2. Keep changes focused and document whether they affect `iOSApp/`, `backend/`, or the GitHub Actions pipeline.
3. Do not commit API keys, private scraped data, personal calendars, Apple signing files, or local Xcode user state.
4. Add or update tests, sample data, or validation notes when changing the scraper or JSON schema.
5. Run the relevant local build or pipeline check before opening a pull request.

## Development checks

For iOS changes, build the SwiftUI app in Xcode. For backend changes, run the scraper locally with a safe test input and verify that the generated opportunity records match the documented schema.

## Pull request expectations

Pull requests should include:

- What changed and why
- Whether the change affects the app, scraper, or data contract
- How the change was validated
- Any privacy, data-source, or API-key considerations

Maintainers may ask for a smaller patch, a clearer schema migration, or more robust source attribution before merging.
