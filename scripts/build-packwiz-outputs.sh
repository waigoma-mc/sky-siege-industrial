#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACK_URL="${PACK_URL:-http://localhost:8080/pack.toml}"
INSTALLER_JAR="${INSTALLER_JAR:-$ROOT_DIR/tools/packwiz-installer-bootstrap.jar}"
MANUAL_MODS_DIR="${MANUAL_MODS_DIR:-$ROOT_DIR/manual-downloads/mods}"
MANUAL_TACZ_DIR="${MANUAL_TACZ_DIR:-$ROOT_DIR/manual-downloads/tacz}"

CLEAN=false
if [[ "${1:-}" == "--clean" ]]; then
  CLEAN=true
elif [[ "${1:-}" != "" ]]; then
  echo "Usage: $0 [--clean]" >&2
  exit 2
fi

if [[ ! -f "$INSTALLER_JAR" ]]; then
  echo "Missing installer: $INSTALLER_JAR" >&2
  echo "Set INSTALLER_JAR=/path/to/packwiz-installer-bootstrap.jar or place it in tools/." >&2
  exit 1
fi

prepare_output() {
  local side="$1"
  local target="$ROOT_DIR/output-$side"

  if [[ "$CLEAN" == true ]]; then
    rm -rf "$target"
  fi

  mkdir -p "$target/mods" "$target/tacz"

  if [[ -d "$MANUAL_MODS_DIR" ]]; then
    shopt -s nullglob
    local manual_mods=("$MANUAL_MODS_DIR"/*.jar)
    shopt -u nullglob

    if (( ${#manual_mods[@]} > 0 )); then
      cp -f "${manual_mods[@]}" "$target/mods/"
    fi
  fi

  if [[ -d "$MANUAL_TACZ_DIR" ]]; then
    shopt -s nullglob
    local manual_tacz_packs=("$MANUAL_TACZ_DIR"/*.zip)
    shopt -u nullglob

    if (( ${#manual_tacz_packs[@]} > 0 )); then
      cp -f "${manual_tacz_packs[@]}" "$target/tacz/"
    fi
  fi
}

install_side() {
  local side="$1"
  local target="$ROOT_DIR/output-$side"

  prepare_output "$side"

  echo "Installing $side pack into $target"
  (
    cd "$target"
    java -jar "$INSTALLER_JAR" -s "$side" "$PACK_URL"
  )
}

install_side client
install_side server

echo "Done."
echo "Client output: $ROOT_DIR/output-client"
echo "Server output: $ROOT_DIR/output-server"
