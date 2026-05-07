#!/usr/bin/env bash

default_preview_pane='true'
default_fzf_window_position='center,70%,80%'
default_fzf_preview_window_position='right,,,nowrap'
default_session_icon='󰐱'
default_window_icon='󰖲'
default_pane_icon='󰆍'
default_indent='▪  '
default_separator='/'

function select_pane() {
    local fzf_version fzf_version_comparison has_border_styling=false
    local current_pane pane target

    current_pane=$(tmux display-message -p '#{pane_id}')

    local -a fzf_args
    fzf_args=(--exit-0 --print-query --reverse --ansi --tmux "${2}" --with-nth=2..)

    fzf_version=$(fzf --version | awk '{print $1}')
    vercomp '0.58.0' "${fzf_version}"
    fzf_version_comparison=$?
    if [[ ${fzf_version_comparison} -ne 1 ]]; then
        fzf_args+=(
            --input-border --input-label=' Search ' --info=inline-right
            --list-border --list-label=' Tmux '
            --preview-border --preview-label=' Preview '
        )
        has_border_styling=true
    fi
    vercomp '0.61.0' "${fzf_version}"
    fzf_version_comparison=$?
    if [[ ${fzf_version_comparison} -ne 1 ]]; then
        fzf_args+=(--ghost 'type to search...')
    fi
    [[ "${has_border_styling}" = false ]] && fzf_args+=(--preview-label=preview)

    if [[ "${1}" = 'true' ]]; then
        fzf_args+=(
            --preview "tmux capture-pane -ep -S -\$(( \${FZF_PREVIEW_LINES:-30} )) -t {1} | awk \"{a[NR]=\\\$0} END{for(i=NR;i>0;i--) if(a[i]~/[^ \\t]/){for(j=1;j<=i;j++) print a[j]; exit}}\" | tail -n \$(( \${FZF_PREVIEW_LINES:-30} ))"
            --preview-window="${3}"
        )
    fi

    local session_icon="${4}" window_icon="${5}" pane_icon="${6}" indent="${7}" separator="${8}"

    export _FZJ_SI="${session_icon}" _FZJ_WI="${window_icon}" _FZJ_PI="${pane_icon}" _FZJ_IN="${indent}" _FZJ_SEP="${separator}"

    _fzj_list() {
        local cs cw cp
        cs=$(tmux display-message -p '#{session_name}')
        cw=$(tmux display-message -p '#{window_index}')
        cp=$(tmux display-message -p '#{pane_id}')
        {
            tmux list-sessions -F '#{session_name} #{session_id} #{session_windows}' | \
                awk -v icon="${_FZJ_SI}" -v cur="${cs}" '{
                    b = ($1==cur) ? "\033[1;38;2;166;227;161m" : ""; r = b!="" ? "\033[0m" : ""
                    printf "%s:00000:00000:0 %s %s%s %s  %s%s\n", $1, $2, b, icon, $1, ($3==1?"":$3" windows"), r
                }'
            tmux list-windows -aF $'#{session_name}\t#{window_index}\t#{session_name}:#{window_index}\t#{window_name}\t#{window_panes}\t#{session_windows}' | \
                awk -F'\t' -v icon="${_FZJ_IN}${_FZJ_WI}" -v sep="${_FZJ_SEP}" -v cur_s="${cs}" -v cur_w="${cw}" '$6 > 1 {
                    b = ($1==cur_s && $2==cur_w) ? "\033[1;38;2;166;227;161m" : ""; r = b!="" ? "\033[0m" : ""
                    printf "%s:%05d:00000:1 %s %s%s %s %s %s  %s%s\n", $1, $2, $3, b, icon, $1, sep, $4, ($5==1?"":$5" panes"), r
                }'
            tmux list-panes -aF $'#{session_name}\t#{window_index}\t#{pane_index}\t#{pane_id}\t#{window_name}\t#{pane_title}\t#{window_panes}' | \
                awk -F'\t' -v icon="${_FZJ_IN}${_FZJ_IN}${_FZJ_PI}" -v sep="${_FZJ_SEP}" -v cur="${cp}" '$7 > 1 {
                    b = ($4==cur) ? "\033[1;38;2;166;227;161m" : ""; r = b!="" ? "\033[0m" : ""
                    printf "%s:%05d:%05d:2 %s %s%s %s %s %s %s %s%s\n", $1, $2, $3, $4, b, icon, $1, sep, $5, sep, $6, r
                }'
        } | sort | cut -d' ' -f2-
    }
    export -f _fzj_list

    fzf_args+=(
        --header '  ctrl-x: kill  ctrl-r: rename  ctrl-n: new'
        --bind $'ctrl-x:execute-silent(t={1}; case $t in \\$*) tmux kill-session -t "$t";; %*) tmux kill-pane -t "$t";; *) tmux kill-window -t "$t";; esac)+reload(bash -c _fzj_list)'
        --bind $'ctrl-r:execute(t={1}; case $t in \\$*) cur=$(tmux display-message -p -t "$t" \'#{session_name}\'); printf "Rename session [%s]: " "$cur"; read -r n; [ -n "$n" ] && tmux rename-session -t "$t" "$n";; %*) cur=$(tmux display-message -p -t "$t" \'#{pane_title}\'); printf "Rename pane [%s]: " "$cur"; read -r n; [ -n "$n" ] && tmux select-pane -t "$t" -T "$n";; *) cur=$(tmux display-message -p -t "$t" \'#{window_name}\'); printf "Rename window [%s]: " "$cur"; read -r n; [ -n "$n" ] && tmux rename-window -t "$t" "$n";; esac)+reload(bash -c _fzj_list)'
        --bind $'ctrl-n:execute(t={1}; case $t in \\$*) printf "New session name: "; read -r n; [ -n "$n" ] && tmux new-session -d -s "$n";; %*) win=$(tmux display-message -p -t "$t" \'#{session_name}:#{window_index}\'); tmux split-window -t "$win" -d;; *) sess=${t%%:*}; printf "New window name: "; read -r n; if [ -n "$n" ]; then tmux new-window -t "$sess:" -n "$n" -d; else tmux new-window -t "$sess:" -d; fi;; esac)+reload(bash -c _fzj_list)'
    )

    pane=$(
        _fzj_list |
        SHELL=/bin/sh fzf "${fzf_args[@]}" |
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

if [[ "${1}" == '--test' ]]; then
    select_pane "${default_preview_pane}" "${default_fzf_window_position}" "${default_fzf_preview_window_position}" \
        "${default_session_icon}" "${default_window_icon}" "${default_pane_icon}" "${default_indent}" "${default_separator}"
    exit
fi

preview_pane="${1}"
fzf_window_position="${2}"
fzf_preview_window_position="${3}"
session_icon="${4}"
window_icon="${5}"
pane_icon="${6}"
indent="${7}"
separator="${8}"

select_pane "${preview_pane}" "${fzf_window_position}" "${fzf_preview_window_position}" "${session_icon}" "${window_icon}" "${pane_icon}" "${indent}" "${separator}"
