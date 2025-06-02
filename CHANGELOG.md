# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.0] - 2025-06-02

### Added

- Show AUR package name after setting it

### Fixed

- Print `.SRCINFO` after generating it
- Set the package name to pkgbase if it exists

## [2.0.0] - 2025-06-02

### Added

- List remaining files after cleaning build files

### Changed

- Change how `srcinfo` argument works. It now is only used to generate `.SRCINFO` if you want to
  include it in your repo.

### Fixed

- Disable `nounset` when sourcing PKGBUILD since `$pkgdir` and `$srcdir` may not be set
- Show `.SRCINFO` contents
- Use archive mode when coping from paths like `dir/.`
- Don't copy `.git` dir

## [1.1.0] - 2025-06-02

### Added

- New outputs - `old_pkgrel` and `new_pkgrel`
- Placeholders to messages
- Automatically derive `aur_pkgname` from PKGBUILD
- Rework the cleaning mechanism

### Fixed

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

[Unreleased]: https://github.com/kamack38/pkgbuild-update/compare/v2.1.0...HEAD
[2.1.0]: https://github.com/kamack38/pkgbuild-update/releases/tag/v2.1.0
[2.0.0]: https://github.com/kamack38/pkgbuild-update/releases/tag/v2.0.0
[1.1.0]: https://github.com/kamack38/pkgbuild-update/releases/tag/v1.1.0
[1.0.1]: https://github.com/kamack38/pkgbuild-update/releases/tag/v1.0.1
[1.0.0]: https://github.com/kamack38/pkgbuild-update/releases/tag/v1.0.0
