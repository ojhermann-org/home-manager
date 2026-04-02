# shellcheck shell=bash
function _set_ps1 {
  local branch git_part
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  git_part=""
  if [[ -n "$branch" ]]; then
    if git status --porcelain 2>/dev/null | grep -q .; then
      git_part="\[\e[37m\]| \[\e[31m\]⎇ ${branch} \[\e[0m\]"
    else
      git_part="\[\e[37m\]| \[\e[32m\]⎇ ${branch} \[\e[0m\]"
    fi
  fi
  PS1="\[\e[33m\]\u@\h \[\e[37m\]| \[\e[36m\]\w \[\e[37m\]| \[\e[35m\]\D{%Y-%m-%d %H:%M:%S} ${git_part}\n\[\e[37m\]> \[\e[0m\]"
}
PROMPT_COMMAND=_set_ps1
