#!/usr/bin/env zsh
# shellcheck shell=bash

target="$1"
to_create=()
current="$target"

while [[ ! -d "$current" && "$current" != "." && "$current" != "/" ]]; do
    to_create+=("$current")
    current="$(dirname "$current")"
done

mkdir -p "$target"

for dir in "${to_create[@]}"; do
    touch "$dir/__init__.py"
done
