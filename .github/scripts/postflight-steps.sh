#!/usr/bin/env bash
# Rewrites goreleaser's quarantine `postflight` block into Homebrew 7's
# declarative `postflight_steps`, in place.
#
# Homebrew 7.0 deprecated `postflight` (an error from 2027-12-11), but
# goreleaser's homebrew_casks.hooks.post.install can only emit it until
# goreleaser/goreleaser#6870 ships (slated for v2.19.0). Emitting the new
# stanza through custom_block instead is not safe: custom_block lands at the
# top of the cask, and `brew style --fix`'s stanza-order autocorrect has been
# seen to delete a moved postflight_steps block and duplicate a neighbouring
# line, which would silently drop quarantine removal. Converting in place
# keeps the block where `postflight` already sat, in stanza order, so nothing
# has to move.
#
# Only the exact one-line xattr hook is rewritten; any other postflight is
# left for `brew style` to flag. Once goreleaser emits postflight_steps
# itself, this matches nothing and is a no-op.
set -euo pipefail

for cask in "$@"; do
  perl -0pi -e '
    s{^([ \t]*)postflight do\n[ \t]*system_command "/usr/bin/xattr", args: \["-dr", "com\.apple\.quarantine", staged_path\] if OS\.mac\?\n[ \t]*end\n}
     {${1}postflight_steps do\n${1}  on_macos do\n${1}    run "/usr/bin/xattr",\n${1}        args:         ["-dr", "com.apple.quarantine", "."],\n${1}        chdir:        ".",\n${1}        must_succeed: false\n${1}  end\n${1}end\n}mg
  ' "$cask"
done
