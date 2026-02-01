#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

fail() { echo "Error: $*" >&2; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"; }

# Public mirror repo (binaries + checksums)
MIRROR_REPO="jmngshi0106-wq/keep-releases"
API_LATEST="https://api.github.com/repos/${MIRROR_REPO}/releases/latest"

# Install contract (matches keep-cli/ci/promote.sh)
INSTALL_BASE="/usr/local/lib/keep"
SYMLINK="/usr/local/bin/keep"

sha256_file() {
  local f="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$f" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$f" | awk '{print $1}'
  else
    fail "No sha256 tool found (need shasum or sha256sum)."
  fi
}

detect_platform() {
  local os arch

  os="$(uname -s)"
  case "$os" in
    Darwin) os="darwin" ;;
    Linux)  os="linux" ;;
    *) fail "Unsupported OS: $(uname -s). Supported: macOS (Darwin), Linux." ;;
  esac

  arch="$(uname -m)"
  if [[ "$arch" == "amd64" ]]; then arch="x86_64"; fi

  case "${os}-${arch}" in
    darwin-arm64) echo "darwin-arm64" ;;
    linux-x86_64) echo "linux-x86_64" ;;
    *)
      fail "Unsupported platform: ${os}-${arch}.
Supported: darwin-arm64, linux-x86_64."
      ;;
  esac
}

resolve_tag_and_version() {
  local tag version json

  if [[ -n "${KEEP_TAG:-}" ]]; then
    tag="$KEEP_TAG"
  elif [[ -n "${KEEP_VERSION:-}" ]]; then
    tag="v${KEEP_VERSION}"
  else
    need_cmd curl
    need_cmd awk
    json="$(curl -fsSL \
      -H "Accept: application/vnd.github+json" \
      -H "User-Agent: keep-installer" \
      "$API_LATEST")" || fail "Could not fetch latest release metadata."

    # Robust extraction: find the "tag_name" key anywhere in the JSON (even if it's one line)
    tag="$(awk -F'"' '{for(i=1;i<=NF;i++){if($i=="tag_name"){print $(i+2); exit}}}' <<<"$json")"
  fi

  [[ -n "${tag:-}" ]] || fail "Could not resolve release tag."
  [[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "Invalid tag format: $tag (expected vX.Y.Z)"

  version="${tag#v}"

  # Return as 2 newline-delimited lines so our global IFS (no space) doesn't break parsing.
  printf '%s\n%s\n' "$tag" "$version"
}

require_permissions_or_refuse() {
  local need_root="0"
  [[ -w "/usr/local/lib" ]] || need_root="1"
  [[ -w "/usr/local/bin" ]] || need_root="1"

  if [[ "${EUID:-$(id -u)}" -ne 0 ]] && [[ "$need_root" == "1" ]]; then
    fail "Insufficient permissions to install into /usr/local.
Re-run with sudo, e.g.:
  curl -fsSL https://raw.githubusercontent.com/jmngshi0106-wq/keep-releases/main/install.sh | sudo bash"
  fi

  if [[ -e "$SYMLINK" ]] && [[ ! -L "$SYMLINK" ]]; then
    fail "$SYMLINK exists and is not a symlink. Refusing.
Remove or rename it manually before installation."
  fi
}

main() {
  need_cmd uname
  need_cmd mktemp
  need_cmd tar
  need_cmd awk
  need_cmd sed
  need_cmd date
  need_cmd cp
  need_cmd mkdir
  need_cmd ln
  need_cmd curl

  local platform tag version asset sha_asset base_url
  local workdir tarball sha_file expected_sha actual_sha
  local extract_dir keep_bin templates_dir
  local install_root bin_dir install_templates_dir installed_at_utc
  local tv

  platform="$(detect_platform)"

  # Read tag + version safely (global IFS has no space)
  mapfile -t tv < <(resolve_tag_and_version)
  tag="${tv[0]}"
  version="${tv[1]}"

  [[ -n "${tag:-}" ]] || fail "Internal error: tag empty after resolve_tag_and_version"
  [[ -n "${version:-}" ]] || fail "Internal error: version empty after resolve_tag_and_version"

  asset="keep-${version}-${platform}.tar.gz"
  sha_asset="${asset}.sha256"
  base_url="https://github.com/${MIRROR_REPO}/releases/download/${tag}"

  workdir="$(mktemp -d "${TMPDIR:-/tmp}/keep-install.XXXXXX")"
  extract_dir="${workdir}/extract"
  mkdir -p "$extract_dir"

  tarball="${workdir}/${asset}"
  sha_file="${workdir}/${sha_asset}"

  echo "==> Keep install"
  echo "==> mirror:   ${MIRROR_REPO}"
  echo "==> tag:      ${tag}"
  echo "==> version:  ${version}"
  echo "==> platform: ${platform}"
  echo

  echo "==> Downloading assets..."
  curl -fsSL -L -o "$tarball" "${base_url}/${asset}" || fail "Download failed: ${base_url}/${asset}"
  curl -fsSL -L -o "$sha_file" "${base_url}/${sha_asset}" || fail "Download failed: ${base_url}/${sha_asset}"

  expected_sha="$(awk '{print $1; exit}' "$sha_file")"
  [[ -n "${expected_sha:-}" ]] || fail "Could not parse sha256 from: $sha_asset"

  echo "==> Verifying sha256..."
  actual_sha="$(sha256_file "$tarball")"
  [[ "$actual_sha" == "$expected_sha" ]] || fail "Checksum mismatch.
expected: $expected_sha
actual:   $actual_sha"

  echo "==> Extracting..."
  tar -xzf "$tarball" -C "$extract_dir"

  keep_bin="${extract_dir}/bin/keep"
  templates_dir="${extract_dir}/templates"
  [[ -x "$keep_bin" ]] || fail "Extracted binary not found/executable at: $keep_bin"
  [[ -d "$templates_dir" ]] || fail "Extracted templates dir not found at: $templates_dir"

  require_permissions_or_refuse

  install_root="${INSTALL_BASE}/${version}"
  bin_dir="${install_root}/bin"
  install_templates_dir="${install_root}/templates"

  if [[ -e "$install_root" ]]; then
    fail "Install root already exists: $install_root
Refusing to overwrite. Remove it manually if you intend to replace."
  fi

  echo "==> Installing..."
  mkdir -p "$bin_dir" "$install_templates_dir"

  cp "$keep_bin" "${bin_dir}/keep"
  cp -R "${templates_dir}/." "$install_templates_dir/"
  chmod +x "${bin_dir}/keep"

  installed_at_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  cat > "${install_root}/receipt.json" <<JSON
{
  "keep_version": "${version}",
  "source": {
    "mirror_repo": "${MIRROR_REPO}",
    "tag": "${tag}",
    "asset": "${asset}",
    "asset_sha256": "${expected_sha}"
  },
  "platform": {
    "os": "$(uname -s | tr '[:upper:]' '[:lower:]')",
    "arch": "$(uname -m)"
  },
  "installed_at_utc": "${installed_at_utc}"
}
JSON
  chmod 0644 "${install_root}/receipt.json"

  ln -sfn "${bin_dir}/keep" "$SYMLINK"

  echo "==> Verifying install..."
  "$SYMLINK" version >/dev/null 2>&1 || fail "Installed keep failed to run: $SYMLINK"

  echo
  echo "==> Install complete"
  echo "==> installed_root: ${install_root}"
  echo "==> symlink:        ${SYMLINK} -> ${bin_dir}/keep"
  echo "==> receipt:        ${install_root}/receipt.json"
  echo
  echo "Next:"
  echo "  keep version"
  echo "  keep init"
}

main "$@"
