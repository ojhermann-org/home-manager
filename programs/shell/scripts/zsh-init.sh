function git-details {
	branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
	if [[ -z "$branch" ]]; then
		echo ""
	elif git status --porcelain 2>/dev/null | grep -q .; then
		echo "%F{white}| %F{red}⎇ ${branch} %f"
	else
		echo "%F{white}| %F{green}⎇ ${branch} %f"
	fi
}
setopt PROMPT_SUBST
export PROMPT='%F{yellow}%n@%m %F{white}| %F{cyan}%~ %F{white}| %F{magenta}%D{%Y-%m-%d %H:%M:%S} $(git-details)
%F{white}> %f'
