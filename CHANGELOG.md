# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- List remaining files after cleaning build files

## [1.1.0] - 2025-06-02

### Added

- New outputs - `old_pkgrel` and `new_pkgrel`
- Placeholders to messages
- Automatically derive `aur_pkgname` from PKGBUILD
- Rework the cleaning mechanism

### Fix

- Add missing `then` keyword

## [1.0.1] - 2025-05-30

### Added

- More verbose logging

### Fixed

- Input handling
- Permissions on ~/.ssh

## [1.0.0] - 2025-05-30

### Added

- Initial release

[Unreleased]: https://github.com/kamack38/pkgbuild-update/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/kamack38/pkgbuild-update/releases/tag/v1.1.0
[1.0.1]: https://github.com/kamack38/pkgbuild-update/releases/tag/v1.0.1
[1.0.0]: https://github.com/kamack38/pkgbuild-update/releases/tag/v1.0.0
