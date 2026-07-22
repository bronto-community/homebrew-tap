# bronto-community Homebrew tap

Homebrew tap for [bronto-cli](https://github.com/bronto-community/bronto-cli),
a community command-line client for the [Bronto](https://bronto.io)
observability platform.

## Install

```sh
brew install bronto-community/tap/bronto
```

Shell completions for bash, zsh, and fish are installed automatically.

## Updating

```sh
brew update && brew upgrade bronto
```

The cask in this repo is maintained automatically by
[goreleaser](https://goreleaser.com/) from bronto-cli's release pipeline —
manual PRs against `Casks/bronto.rb` will be overwritten by the next
release. Report install problems on the
[bronto-cli issue tracker](https://github.com/bronto-community/bronto-cli/issues).

## Verifying artifacts

Every bronto-cli release ships a cosign-signed `checksums.txt` and
per-archive SBOMs — see the
[security policy](https://github.com/bronto-community/bronto-cli/blob/main/SECURITY.md)
for the verification one-liner.
