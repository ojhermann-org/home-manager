#!/usr/bin/env bash
# shellcheck shell=bash

mkdir -p "$(dirname "$1")"
printf '#!/usr/bin/env bash\n# shellcheck shell=bash\n' > "$1"
