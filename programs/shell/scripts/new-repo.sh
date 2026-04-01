#!/usr/bin/env bash
# shellcheck shell=bash

GITHUB_SETTINGS_REPO="${GITHUB_SETTINGS_REPO:-$HOME/Documents/github-settings}"

name=""
description=""
checks=""

usage() {
  printf 'Usage: new-repo --name <name> --description <description> [--checks <job1,job2>]\n' >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      name="$2"
      shift 2
      ;;
    --description)
      description="$2"
      shift 2
      ;;
    --checks)
      checks="$2"
      shift 2
      ;;
    -h | --help)
      usage
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage
      ;;
  esac
done

if [[ -z "$name" || -z "$description" ]]; then
  usage
fi

repositories_tf="${GITHUB_SETTINGS_REPO}/repositories.tf"

if [[ ! -f "$repositories_tf" ]]; then
  printf 'Error: %s not found\nSet GITHUB_SETTINGS_REPO to override (current: %s)\n' \
    "$repositories_tf" "$GITHUB_SETTINGS_REPO" >&2
  exit 1
fi

# HCL module identifiers use underscores, not hyphens
module_id="${name//-/_}"

original_lines=$(wc -l < "$repositories_tf")

{
  printf '\nmodule "%s" {\n' "$module_id"
  printf '  source      = "./modules/standard_repo"\n'
  printf '  name        = "%s"\n' "$name"
  printf '  description = "%s"\n' "$description"
  if [[ -n "$checks" ]]; then
    checks_csv="${checks//,/\", \"}"
    printf '  required_status_checks = ["%s"]\n' "$checks_csv"
  fi
  printf '}\n'
} >> "$repositories_tf"

cd "$GITHUB_SETTINGS_REPO" || exit 1
tofu plan

printf '\nApply this plan? [y/N] '
read -r confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  head -n "$original_lines" "$repositories_tf" > "${repositories_tf}.tmp"
  mv "${repositories_tf}.tmp" "$repositories_tf"
  printf 'Aborted. No changes made.\n'
  exit 0
fi

tofu apply -auto-approve
