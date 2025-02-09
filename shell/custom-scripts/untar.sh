#!/bin/bash
set -e # Avsluta skriptet vid första felet

# verbose flag
VERBOSE=false
if [[ "$1" == "--verbose" ]]; then
  VERBOSE=true
  shift
fi

untar() {
  if [ -z "$1" ]; then
    echo "Usage: untar <archive_file>"
    return 1
  fi

  local file="$1"

  # verify file existence
  if [ ! -f "$file" ]; then
    echo "Error: File '$file' does not exist!"
    return 1
  fi

  local output_dir
  output_dir="${PWD}/$(basename "$file" | sed -E 's/\.(tar\.[a-z0-9]+|zip)$//')"

  mkdir -p "$output_dir"

  case "$file" in
  *.tar.gz | *.tgz)
    CMD="tar -xz${VERBOSE:+v}f"
    ;;
  *.tar.xz)
    CMD="tar -xJ${VERBOSE:+v}f"
    ;;
  *.tar.bz2)
    CMD="tar -xj${VERBOSE:+v}f"
    ;;
  *.tar)
    CMD="tar -x${VERBOSE:+v}f"
    ;;
  *.zip)
    CMD="unzip"
    ;;
  *)
    echo "Error: Unsupported archive format for '$file'. Supported formats: .tar.gz, .tgz, .tar.xz, .tar.bz2, .tar, .zip"
    return 1
    ;;
  esac

  # run extraction
  if [[ "$file" == *.zip ]]; then
    $CMD "$file" -d "$output_dir"
  else
    $CMD "$file" -C "$output_dir"
  fi

  echo "Files have been extracted to: $output_dir"
}

# run function if scripts is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  untar "$@"
fi
