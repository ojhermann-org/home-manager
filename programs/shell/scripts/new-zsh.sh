#!/usr/bin/env zsh
# shellcheck shell=bash

mkdir -p "$(dirname "$1")"
printf '#!/usr/bin/env zsh\n# shellcheck shell=bash\n' > "$1"
