# Notes for working in this tap

## Tap trust: a fully qualified install needs no `brew tap` or `brew trust`

Homebrew 6.0.0 made non-official taps require explicit trust, and it is easy to
over-correct from that headline into telling users to run `brew trust`. Don't.
Per `docs/Tap-Trust.md` in the Homebrew repository:

> Installing a fully qualified formula or cask name trusts only that item.

> An untrusted tap is not loaded when tap trust is required **unless you
> explicitly install a fully qualified formula or cask from that tap**.

So this is the whole install instruction, and it always has been:

```sh
brew install bronto-community/tap/bronto
```

No `brew tap` first (the fully qualified name taps it), no `brew trust`
(installing that name grants trust to that one cask), and no interactive
prompt — `Trust.require_trusted_cask!` raises, it never asks.

The mechanism is `Trust::explicitly_allowed?` in `Library/Homebrew/trust.rb`:
trust is satisfied when the fully qualified name, the tap name, or
`--tap=<tap>` appears anywhere in `ARGV`. That is why CI needs no trust step
either — `brew style <tap>` and `brew audit --cask <tap>/<cask>` both name
their target on the command line.

`brew trust --tap` grants trust to **all current and future** items in the tap.
The docs explicitly prefer per-item trust, so recommending whole-tap trust is a
gratuitous over-grant. Never put it in user-facing install instructions.

**Where this went wrong**, so it isn't repeated: a CI log printed
`The following taps are not trusted: ... Homebrew is currently ignoring
formulae, casks and commands from these taps`, and I concluded from that
warning alone that a trust step was required. It wasn't — the warning came from
an unrelated `brew` invocation in the same step (a dependency install that
named no tap), and the actual failure was a style offence. A `brew trust --tap`
step then went into CI and into both READMEs on the strength of a message I had
not tested against.

To check a claim like this, create a deliberately untrusted tap and run the
command against it:

```sh
VT="$(brew --repository)/Library/Taps/trusttest/homebrew-tap"
mkdir -p "$VT/Casks" && cp Casks/<cask>.rb "$VT/Casks/"
brew audit --cask --strict trusttest/tap/<cask>   # exit 0 while untrusted
brew style trusttest/tap                          # loads fine while untrusted
rm -rf "$(brew --repository)/Library/Taps/trusttest"
```

A warning in a log is not proof that a command fails.

## `brew style` disagrees between Homebrew versions

The runner's brew and a local brew enforce different cask cops on identical
files. Observed on the same `bronto.rb`: the runner flagged
`Style/IfUnlessModifier` and a trailing blank line and no stanza-order
offences; local brew 6.0.20 flagged the stanza offences and not
`IfUnlessModifier`. They have also disagreed about `name` stanza placement.

Consequences:

- **Local `brew style` output is not authoritative.** Don't treat a local pass
  as evidence CI will pass, or a local failure as evidence it will fail.
- **Never commit a local `brew style --fix`.** The Audit workflow normalizes on
  `main`, so hand-normalizing starts a fight with the next CI run.

## The casks are generated

`Casks/*.rb` come from goreleaser in the upstream repos. Editing them here is
futile — the next release overwrites the file. Fix the `homebrew_casks:` block
in the upstream `.goreleaser.yaml` instead.

goreleaser's built-in cask template is not `brew style`-clean and offers no
knob to change that, which is why the workflow normalizes style on `main`
rather than failing on every release. `custom_block` is injected at the *top*
of the cask, so anything placed there (e.g. `depends_on`) will be relocated by
normalization — expected, not a problem.
