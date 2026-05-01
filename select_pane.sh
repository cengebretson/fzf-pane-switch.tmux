#!/usr/bin/env bash
function select_pane() {
    local border_styling="" fzf_version fzf_version_comparison
    local current_pane pane target preview

    # Save the currently active pane ID
    current_pane=$(tmux display-message -p '#{pane_id}')

    # Setup border styling
    fzf_version=$(fzf --version | awk '{print $1}')
    vercomp '0.58.0' "${fzf_version}"
    fzf_version_comparison=$?
    if [[ ${fzf_version_comparison} -ne 1 ]]; then
        border_styling+=" --input-border --input-label=' Search ' --info=inline-right"
        border_styling+=" --list-border --list-label=' Tmux '"
        border_styling+=" --preview-border --preview-label=' Preview '"
    fi
    vercomp '0.61.0' "${fzf_version}"
    fzf_version_comparison=$?
    if [[ ${fzf_version_comparison} -ne 1 ]]; then
        border_styling+=" --ghost 'type to search...'"
    fi
    if [[ -z "${border_styling}" ]]; then
        border_styling="--preview-label='preview'"
    fi

    # Check if we're using the fzf preview pane
    if [[ "${1}" = 'true' ]]; then
        preview="--preview '"
        preview+="tmux capture-pane -ep -S -\$(( \${FZF_PREVIEW_LINES:-30} )) -t {1} | "
        # The awk below removes trailing empty/whitespace-only lines by finding the last non-empty line and printing up to that point
        preview+="awk \"{a[NR]=\\\$0} END{for(i=NR;i>0;i--) if(a[i]~/[^ \\t]/){for(j=1;j<=i;j++) print a[j]; exit}}\" | "
        preview+="tail -n \$(( \${FZF_PREVIEW_LINES:-30} ))"
        preview+="' --preview-window=${3}"
    fi

    local session_icon="${4}" window_icon="${5}" pane_icon="${6}" indent="${7}"

    # Build combined list grouped by session > window > pane.
    # Each line is prefixed with a sort key (session:window_idx:pane_idx:type) so that
    # a single sort produces the correct nesting order without nested tmux calls.
    # The ▸ / ▹▹ prefixes on the icon provide the visual indent level.
    # Field 1 (hidden): tmux switch-client target ($session_id, session:window, %pane_id)
    # Field 2 (visible): indented icon
    # Fields 3+ (visible): display info
    pane=$(
        {
            tmux list-sessions -F '#{session_name} #{session_id} #{session_windows}' | \
                awk -v icon="${session_icon}" '{
                    printf "%s:00000:00000:0 %s %s %s  %s windows\n", $1, $2, icon, $1, $3
                }'

            tmux list-windows -aF '#{session_name} #{window_index} #{session_name}:#{window_index} #{window_name} #{window_panes}' | \
                awk -v icon="${indent}${window_icon}" '{
                    printf "%s:%05d:00000:1 %s %s %s  %s  %s panes\n", $1, $2, $3, icon, $1, $4, $5
                }'

            tmux list-panes -aF '#{session_name} #{window_index} #{pane_index} #{pane_id} #{window_name} #{pane_current_command} #{window_panes}' | \
                awk -v icon="${indent}${indent}${pane_icon}" '$7 > 1 {
                    printf "%s:%05d:%05d:2 %s %s %s  %s  %s  %s\n", $1, $2, $3, $4, icon, $4, $1, $5, $6
                }'
        } | sort | cut -d' ' -f2- |
        eval SHELL=/bin/sh fzf --exit-0 --print-query --reverse --tmux "${2}" --with-nth=2.. "${border_styling}" "${preview}" |
        tail -1
    )

    target=$(echo "${pane}" | awk '{print $1}')

    if [[ -z "${target}" ]]; then
        tmux switch-client -t "${current_pane}"
    else
        tmux switch-client -t "${target}"
    fi
}

function vercomp() {
  local v1="$1"
  local v2="$2"

  IFS='.' read -r -a ver1 <<< "$v1"
  IFS='.' read -r -a ver2 <<< "$v2"

  for i in 0 1 2; do
    local num1="${ver1[i]:-0}"
    local num2="${ver2[i]:-0}"

    if (( num1 > num2 )); then
      return 1
    elif (( num1 < num2 )); then
      return 2
    fi
  done

  return 0
}

# Check for required commands
command -v tmux >/dev/null 2>&1 || { echo "tmux not found"; exit 1; }
command -v fzf >/dev/null 2>&1 || { echo "fzf not found"; exit 1; }

preview_pane="${1}"
fzf_window_position="${2}"
fzf_preview_window_position="${3}"
session_icon="${4}"
window_icon="${5}"
pane_icon="${6}"
indent="${7}"

select_pane "${preview_pane}" "${fzf_window_position}" "${fzf_preview_window_position}" "${session_icon}" "${window_icon}" "${pane_icon}" "${indent}"
