# shellcheck shell=bash

force=false
if [[ "${1:-}" == "--force" ]]; then
  force=true
fi

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

if [[ "$current_version" == "$latest_version" ]] && [[ "$force" == false ]]; then
  echo "claude-code: already at $latest_version"
  exit 0
fi

echo "claude-code: $current_version -> $latest_version"

fetch_sri_hash() {
  local pkg="$1"
  local url="https://registry.npmjs.org/@anthropic-ai/claude-code-${pkg}/-/claude-code-${pkg}-${latest_version}.tgz"
  local raw_hash
  raw_hash=$(nix-prefetch-url --unpack "$url" 2>/dev/null)
  nix hash to-sri --type sha256 "$raw_hash"
}

darwin_arm64_hash=$(fetch_sri_hash "darwin-arm64")
linux_x64_hash=$(fetch_sri_hash "linux-x64")
linux_arm64_hash=$(fetch_sri_hash "linux-arm64")

sed -i "s|version = \"${current_version}\";|version = \"${latest_version}\";|" "$nix_file"
sed -i "/pkg = \"darwin-arm64\"/{n;s|hash = \"sha256-[^\"]*\";|hash = \"${darwin_arm64_hash}\";|}" "$nix_file"
sed -i "/pkg = \"linux-x64\"/{n;s|hash = \"sha256-[^\"]*\";|hash = \"${linux_x64_hash}\";|}" "$nix_file"
sed -i "/pkg = \"linux-arm64\"/{n;s|hash = \"sha256-[^\"]*\";|hash = \"${linux_arm64_hash}\";|}" "$nix_file"

echo "claude-code: updated to $latest_version"
