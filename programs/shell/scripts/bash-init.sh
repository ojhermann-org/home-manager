function git-details {
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -z "$branch" ]]; then
    echo ""
  elif git status --porcelain 2>/dev/null | grep -q .; then
    echo "\[\e[37m\]| \[\e[31m\]⎇ ${branch} \[\e[0m\]"
  else
    echo "\[\e[37m\]| \[\e[32m\]⎇ ${branch} \[\e[0m\]"
  fi
}
PS1='\[\e[33m\]\u@\h \[\e[37m\]| \[\e[36m\]\w \[\e[37m\]| \[\e[35m\]\D{%Y-%m-%d %H:%M:%S} $(git-details)\n\[\e[37m\]> \[\e[0m\]'
