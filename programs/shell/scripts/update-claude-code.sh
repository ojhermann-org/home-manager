# shellcheck shell=bash

repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ -z "$repo_root" ]]; then
  echo "update-claude-code: not inside a git repository" >&2
  exit 1
fi

nix_file="$repo_root/packages/claude-code.nix"
if [[ ! -f "$nix_file" ]]; then
  echo "update-claude-code: $nix_file not found" >&2
  exit 1
fi

current_version=$(grep 'version = "' "$nix_file" | sed 's/.*version = "\(.*\)";/\1/')
latest_version=$(curl -fsSL https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r .version)

if [[ "$current_version" == "$latest_version" ]]; then
  echo "claude-code: already at $latest_version"
  exit 0
fi

echo "claude-code: $current_version -> $latest_version"

tarball_url="https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${latest_version}.tgz"
raw_hash=$(nix-prefetch-url --unpack "$tarball_url" 2>/dev/null)
sri_hash=$(nix hash to-sri --type sha256 "$raw_hash")

sed -i "s|version = \"${current_version}\";|version = \"${latest_version}\";|" "$nix_file"
sed -i "s|hash = \"sha256-[^\"]*\";|hash = \"${sri_hash}\";|" "$nix_file"

echo "claude-code: updated to $latest_version"
