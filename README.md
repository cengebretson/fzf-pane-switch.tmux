<h1 align="center">
    🔀 TMUX FZF Pane Switch
</h1>

![Demonstration of tmux-fzf-pane-switch in action](assets/tmux-fzf-pane-switch-demo.gif)

Switch to any TMUX session, window, or pane using fzf. The list is grouped hierarchically — sessions at the top, windows beneath their session, and panes beneath their window (only shown when a window has more than one pane).

## Requirements

* [fzf](https://github.com/junegunn/fzf) >= 0.53.0 (requires the `--tmux` option).
* [tmux](https://github.com/tmux/tmux) >= 3.3.
* A [Nerd Font](https://www.nerdfonts.com/) for the default icons (configurable — see below).

> [!NOTE]
> To get the border styling as shown in the image above, you need fzf version >= 0.58.0.

## Installation

### Using TPM (recommended)

1. Install [TPM (Tmux Plugin Manager)](https://github.com/tmux-plugins/tpm).

2. Add `tmux-fzf-pane-switch` to your `~/.tmux.conf`:

    ```bash
    set -g @plugin 'kristijan/fzf-pane-switch.tmux'
    ```

3. Start tmux and install the plugin.

    Press `<tmux_prefix> + I` (capital i, as in Install) to install the plugin.

    Press `<tmux_prefix> + U` (capital u, as in Update) to update the plugin.

### Manual installation

1. Clone this repository to your desired location:

    ```bash
    git clone https://github.com/kristijan/fzf-pane-switch.tmux.git ~/.tmux/plugins/fzf-pane-switch.tmux
    ```

2. Add the following to your `~/.tmux.conf`:

    ```bash
    run-shell ~/.tmux/plugins/fzf-pane-switch.tmux/select_pane.tmux
    ```

    Any customisation variables should be set **BEFORE** the `run-shell` line so they're correctly sourced.

3. Reload your tmux configuration:

    ```bash
    tmux source-file ~/.tmux.conf
    ```

## Customise

You can override the following options in your `tmux.conf` file.

### Key binding

```bash
set -g @fzf_pane_switch_bind-key "key binding"
```

Default is `prefix + s`, which replaces the tmux default session select (tmux default: `choose-tree -Zs -O name`)

### fzf window position

```bash
set -g @fzf_pane_switch_window-position "position"
```

Default is `center,70%,80%`. You can use any options allowed [https://man.archlinux.org/man/fzf.1.en#tmux](https://man.archlinux.org/man/fzf.1.en#tmux).

### fzf pane preview

```bash
set -g @fzf_pane_switch_preview-pane "[true|false]"
```

Default is `true`

### fzf pane preview position

Only when `@fzf_pane_switch_preview-pane` is `true`.

```bash
set -g @fzf_pane_switch_preview-pane-position "position"
```

Default is `right,,,nowrap`. You can use any options allowed [https://man.archlinux.org/man/fzf.1.en#preview~3](https://man.archlinux.org/man/fzf.1.en#preview~3).

### Icons

Each entry type has a configurable icon. The defaults require a [Nerd Font](https://www.nerdfonts.com/).

```bash
set -g @fzf_pane_switch_session-icon "󰐱"
set -g @fzf_pane_switch_window-icon  "󰖲"
set -g @fzf_pane_switch_pane-icon    "󰘗"
```

Any string works — including plain text fallbacks if you don't have a Nerd Font:

```bash
set -g @fzf_pane_switch_session-icon "S"
set -g @fzf_pane_switch_window-icon  "W"
set -g @fzf_pane_switch_pane-icon    "P"
```

### Indent

The indent string is prepended to the icon once for windows and twice for panes, creating the visual hierarchy.

```bash
set -g @fzf_pane_switch_indent "· "
```

Default is `· ` (middle dot + space). Set to an empty string for no indentation, or use any character(s) you prefer (e.g. `▸ `, `  `).

## Tools used in demonstration

* TMUX theme is [catppuccin](https://github.com/catppuccin/tmux) mocha.
* ZSH shell prompt is [starship](https://starship.rs)
* `fzf` theme is [catppuccin](https://github.com/catppuccin/fzf) mocha.

## Inspiration

I pretty much retrofitted the [brokenricefilms/tmux-fzf-session-switch](https://github.com/brokenricefilms/tmux-fzf-session-switch) TPM plugin. So, if you're looking for something to switch tmux sessions only, go check it out.

## Other plugins

Check out my other plugin [TMUX Flash Copy](https://github.com/Kristijan/flash-copy.tmux), that enables you to search visible words in the current tmux pane, then copy that word to the system clipboard by pressing the associated label key.
