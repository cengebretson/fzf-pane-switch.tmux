# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A tmux plugin (TPM-compatible) that lets users switch to any pane across all sessions using fzf as a fuzzy finder. Two files do all the work:

- `select_pane.tmux` — sourced by tmux at startup; reads user config options via `tmux show-option`, then registers a key binding that calls `select_pane.sh` with the resolved options as arguments.
- `select_pane.sh` — invoked by tmux when the key binding fires; builds and runs the fzf command, then switches to the selected pane or offers to create a new window.

## How the two scripts connect

`select_pane.tmux` passes four positional arguments to `select_pane.sh`:

1. `preview_pane` (`true`/`false`)
2. `fzf_window_position` (passed to `fzf --tmux`)
3. `fzf_preview_window_position` (passed to `fzf --preview-window`)
4. `list_panes_format` (space-separated tmux FORMAT tokens, e.g. `pane_id session_name window_name`)

`select_pane.sh` converts the format token list into a `tmux list-panes -aF` format string and feeds the output into fzf. The first field of each line is always `#{pane_id}` (hidden from fzf via `--with-nth=2..`) and is used to switch to the selected pane.

## Testing

There is no automated test suite. Test manually inside a live tmux session:

```bash
# Reload the plugin after changes
tmux source-file ~/.tmux.conf

# Or invoke select_pane.sh directly for quick iteration
bash select_pane.sh true center,70%,80% right,,,nowrap "pane_id session_name window_name pane_title pane_current_command"
```

## Version-gated fzf features

`select_pane.sh` uses `vercomp` to detect fzf version at runtime and enables richer border/label styling (≥0.58.0) and ghost text (≥0.61.0) only when available. Keep this pattern when adding features that depend on a minimum fzf version.

## Configurable tmux options

All user-facing options use the prefix `@fzf_pane_switch_` and are read with `get_tmux_option` in `select_pane.tmux`. The defaults are defined as `default_*` variables at the top of that file.
