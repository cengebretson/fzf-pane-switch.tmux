#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
default_bind_key='s'
default_preview_pane='true'
default_fzf_window_position='center,70%,80%'
default_fzf_preview_window_position='right,,,nowrap'
default_session_icon='󰐱'
default_window_icon='󰖲'
default_pane_icon='󰘗'
default_indent='· '

# User overridable options
tmux_bind_key="@fzf_pane_switch_bind-key"
tmux_preview_pane="@fzf_pane_switch_preview-pane"
tmux_fzf_window_position="@fzf_pane_switch_window-position"
tmux_fzf_preview_window_position="@fzf_pane_switch_preview-pane-position"
tmux_session_icon="@fzf_pane_switch_session-icon"
tmux_window_icon="@fzf_pane_switch_window-icon"
tmux_pane_icon="@fzf_pane_switch_pane-icon"
tmux_indent="@fzf_pane_switch_indent"

get_tmux_option() {
    local option="${1}"
    local default_value="${2}"
    local option_override
    option_override="$(tmux show-option -gqv "${option}")"
    if [ -z "${option_override}" ]; then
        echo "${default_value}"
    else
        echo "${option_override}"
    fi
}

set_switch_pane_bindings() {
    local bind_key preview_pane fzf_window_position fzf_preview_window_position
    local session_icon window_icon pane_icon indent
    bind_key="$(get_tmux_option "${tmux_bind_key}" "${default_bind_key}")"
    preview_pane="$(get_tmux_option "${tmux_preview_pane}" "${default_preview_pane}")"
    fzf_window_position="$(get_tmux_option "${tmux_fzf_window_position}" "${default_fzf_window_position}")"
    fzf_preview_window_position="$(get_tmux_option "${tmux_fzf_preview_window_position}" "${default_fzf_preview_window_position}")"
    session_icon="$(get_tmux_option "${tmux_session_icon}" "${default_session_icon}")"
    window_icon="$(get_tmux_option "${tmux_window_icon}" "${default_window_icon}")"
    pane_icon="$(get_tmux_option "${tmux_pane_icon}" "${default_pane_icon}")"
    indent="$(get_tmux_option "${tmux_indent}" "${default_indent}")"

    tmux bind-key "${bind_key}" run-shell \
        "'${CURRENT_DIR}/select_pane.sh' '${preview_pane}' '${fzf_window_position}' '${fzf_preview_window_position}' '${session_icon}' '${window_icon}' '${pane_icon}' '${indent}'"
}

set_switch_pane_bindings
