# PKGBUILD update action

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/kamack38/pkgbuild-update/CD.yml?label=CI&style=flat-square)](https://github.com/kamack38/pkgbuild-update/actions)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/kamack38/pkgbuild-update?style=flat-square)](https://github.com/kamack38/pkgbuild-update/releases)
[![GitHub](https://img.shields.io/github/license/kamack38/pkgbuild-update?style=flat-square)](./LICENSE)

This action is for updating PKGBUILDs for AUR packages

## Features

- Updating `pkgver`, `pkgrel` manually (via a workflow input)
- Updating package version using the `pkgver()` function
- Validating the new PKGBUILD by building it
- Generating [.SRCINFO](https://wiki.archlinux.org/title/.SRCINFO) based on the PKGBUILD
- Pushing the new package to AUR
- Using [paru](https://github.com/Morganamilo/paru) for resolving dependencies

## Usage

### Requirements

- A [PKGBUILD](https://wiki.archlinux.org/title/PKGBUILD) file inside your repository.
- Use [actions/checkout](https://github.com/actions/checkout) in previous step. This is important,
  unless you want your
  [$GITHUB_WORKSPACE](https://docs.github.com/en/actions/reference/environment-variables#default-environment-variables)
  folder to be empty.

### Inputs

Following inputs can be used as `step.with` keys:

| Name                | Type    | Description                                                                                      | Default                                | Required |
| ------------------- | ------- | ------------------------------------------------------------------------------------------------ | -------------------------------------- | -------- |
| path                | String  | Location for this action to run                                                                  |                                        | `false`  |
| pkgver              | String  | New `pkgver` for PKGBUILD                                                                        |                                        | `false`  |
| pkgrel              | Integer | New `pkgrel` for PKGBUILD                                                                        |                                        | `false`  |
| updpkgsums          | Boolean | Update checksums on PKGBUILD                                                                     | `true`                                 | `false`  |
| srcinfo             | Boolean | Generate new `.SRCINFO`. It is automatically generated when pushing to AUR                       | `true`                                 | `false`  |
| build               | Boolean | Whether to build the package after updating it to validate the new version                       | `false`                                | `false`  |
| flags               | String  | Flags for `makepkg`                                                                              | `-cfs --noconfirm`                     | `false`  |
| paru                | Boolean | Resolve dependencies using paru                                                                  | `false`                                | `false`  |
| aur_pkgname         | String  | AUR package name. Defaults to the one provided in PKGBUILD                                       |                                        | `false`  |
| aur_commit_username | String  | The username to use when pushing package to the AUR                                              |                                        | `false`  |
| aur_commit_email    | String  | The email to use when pushing package to the AUR                                                 |                                        | `false`  |
| aur_commit_message  | String  | Commit message to use when pushing package to the AUR. Can contain [placeholders](#Placeholders) | `Updating $AUR_PKGNAME to $NEW_PKGVER` | `false`  |
| aur_ssh_private_key | String  | Your private key with access to the AUR package.                                                 |                                        | `false`  |
| aur_force_push      | String  | Use --force when pushing to the AUR.                                                             | `false`                                | `false`  |

### Outputs

This action has the following outputs that can be accessed as
`${{ steps.<step-id>.outputs.<output-name> }}`:

| Name       | Type   | Description                                                                   |
| ---------- | ------ | ----------------------------------------------------------------------------- |
| old_pkgver | String | The package version obtained before updating the package                      |
| new_pkgver | String | The package version after updating it (may be the same as `old_pkgver`)       |
| old_pkgrel | String | The package release number obtained before setting it                         |
| new_pkgrel | String | The package release number after setting it (may be the same as `old_pkgrel`) |

### Placeholders

Placeholders are special strings that are expanded in the workflow. The available are.

- `$AUR_PKGNAME` - the same as `$INPUT_AUR_PKGNAME`
- `$OLD_PKGVER` - the version before updating
- `$NEW_PKGVER` - the version after updating

### Examples

#### 1. Basic

This workflow will change `pkgver` and `pkgrel` to the specified ones, update checksums and then
generate a new `.SRCINFO`.

```yaml
name: CI

on:
  push:
    branches: main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate package
        uses: kamack38/pkgbuild-update@v1
        id: update
        with:
          pkgver: "1.2.3"
          pkgrel: "2"

      - name: Print the new versions
        run: echo "The package version was updated from ${{ steps.update.outputs.old_pkgver }} to ${{ steps.update.outputs.new_pkgver }}"
```

#### 2. Pushing to aur

This workflow will get the new package version using `pkgver()`, update checksums, generate new
`.SRCINFO` and then push changes to the AUR.

```yaml
name: CI

on:
  push:
    branches: main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Validate package
        uses: kamack38/pkgbuild-update@v1
        id: update
        with:
          path: packages/my-package
          aur_pkgname: my-package
          aur_commit_username: ${{ secrets.AUR_USERNAME }}
          aur_commit_email: ${{ secrets.AUR_EMAIL }}
          aur_ssh_private_key: ${{ secrets.AUR_SSH_PRIVATE_KEY }}

      - name: Print the new versions
        run: echo "The package version was updated from ${{ steps.update.outputs.old_pkgver }} to ${{ steps.update.outputs.new_pkgver }}"
```

## Roadmap

- [ ] Push updates to the repo
  - [ ] Push with `--rebase`
  - [ ] Support placeholders in commit messages
  - [ ] Set commit author

## Credits

This action is heavily inspired by
[heyhusen/archlinux-package-action](https://github.com/heyhusen/archlinux-package-action).

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE)
