# superpowers extensions: maintainer notes

This repo contains only my own additions to superpowers. See README.md for how each piece reaches Claude Code.

- **Don't vendor upstream.** Upstream superpowers comes from the official marketplace plugin, which updates itself. Don't copy upstream skills into this repo, and don't merge from obra/superpowers.
- **Don't patch the plugin cache** (`~/.claude/plugins/cache/...`). Updates overwrite it. To change how an upstream skill behaves, add or edit an `extensions/<skill-name>.md` that layers on top of it.
- **Write extensions against stable anchors.** Refer to concepts ("before presenting the options menu"), not step numbers, because upstream renumbers steps.
- **Test skill changes.** Use `superpowers:writing-skills` when editing `skills/smoke-testing/`, and pressure-test changes to behavior-shaping text before relying on them.
- **Never open PRs to obra/superpowers** from this repo.
