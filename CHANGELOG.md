# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-09-04

### ⚠️ Breaking Changes
- **ICU library requirement**: The gem now requires the ICU library to be installed on the system. This may affect macOS and Windows users who previously relied on twitter_cldr's bundled ICU data.
  - **Linux**: Usually pre-installed
  - **macOS**: Install via Homebrew: `brew install icu4c`
  - **Windows**: May require manual ICU installation
  - **Custom path**: Set `ICU_LIB_PATH` environment variable if ICU is installed in a non-standard location

### Customer-Impacting Changes

#### Added
- **Extended platform support**: Added ARM64 architecture support in CI/CD pipeline

#### Changed
- **Dependencies**: Replaced twitter_cldr with direct FFI bindings (lighter dependency footprint, but requires system ICU library)
- **Performance**: Direct ICU integration provides better performance for text processing

### Internal Changes

#### Testing & Quality
- Added comprehensive integration tests for BiDi functionality
- Extended CI matrix to include Ubuntu 22.04, 24.04 and ARM64 variants

## [0.1.8] - 2025-09-04

### Customer-Impacting Changes

#### Added
- **Ruby 2.7+ requirement**: Gem now explicitly requires Ruby 2.7 or higher
- **Better documentation**: All public APIs now have YARD documentation with examples

### Internal Changes

#### Development & CI
- Migrated from Travis CI to GitHub Actions
- Added testing matrix for Ruby 2.7, 3.0, 3.1, 3.2, 3.3, and 3.4
- Added RuboCop linting to CI workflow
- Added Dependabot for automated dependency updates
- Added CLAUDE.md for AI-assisted development guidance
- Multi-factor authentication (MFA) is now required for gem publishers

#### Code Quality
- Added YARD documentation to all modules and classes
- Fixed some RuboCop violations
- Fixed typos
- Improved gemspec metadata (added source_code_uri, changelog_uri, bug_tracker_uri, documentation_uri)
- Moved development dependencies from gemspec to Gemfile
- Removed unnecessary `$LOAD_PATH` manipulation
- Internal file requires now use `require_relative` for faster loading
- Gemspec file inclusion no longer depends on git, works in any environment

#### Documentation
- Updated README with "Supported Languages" section
- Updated gemspec description to accurately reflect RTL language support
- Added comprehensive code examples in YARD documentation

## [0.1.7] - 2020-05-10

For changes in previous versions, see the git commit history.