#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) morpheby
#
# Package the assembled sysroot into a tarball for GitHub Releases / xpm.
#
# Expected environment variables:
#   VERSION   - release version string, e.g. "21.1.8-1"  (required)
#   DIST_DIR  - sysroot assembly directory (default: $WORKSPACE/rv32-llvm-picolibc)
#   OUTDIR    - output directory for the tarball (default: current directory)
#   WORKSPACE - root working directory (default: $HOME/workspace)
#
# Outputs:
#   $OUTDIR/rv32-llvm-picolibc-<VERSION>.tar.gz
#   $OUTDIR/rv32-llvm-picolibc-<VERSION>.tar.gz.sha256

set -e -o pipefail

if [[ -z "${VERSION}" ]]; then
  echo "ERROR: VERSION environment variable is required (e.g. '21.1.8-1')" >&2
  exit 1
fi

WORKSPACE="${WORKSPACE:-$HOME/workspace}"
DIST_DIR="${DIST_DIR:-$WORKSPACE/rv32-llvm-picolibc}"
OUTDIR="${OUTDIR:-$(pwd)}"
ROOT_DIR="${ROOT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

TARNAME="rv32-llvm-picolibc-${VERSION}"
OUTFILE="${OUTDIR}/${TARNAME}.tar.gz"

echo "==> Packaging ${TARNAME} from ${DIST_DIR}/dist"

TMPDIR_PKG="$(mktemp -d)"
trap 'rm -rf "${TMPDIR_PKG}"' EXIT

mkdir -p "${TMPDIR_PKG}/${TARNAME}"
cp -R "${DIST_DIR}/dist" "${TMPDIR_PKG}/${TARNAME}/"

if [ -d "${ROOT_DIR}/cmake" ]; then
  mkdir -p "${TMPDIR_PKG}/${TARNAME}/cmake"
  cp "${ROOT_DIR}/cmake/"*.cmake "${TMPDIR_PKG}/${TARNAME}/cmake/"
  echo "==> Included cmake toolchain files from ${ROOT_DIR}/cmake"
fi

tar czf "${OUTFILE}" -C "${TMPDIR_PKG}" "${TARNAME}"

sha256sum "${OUTFILE}" | awk '{print $1}' > "${OUTFILE}.sha256"

echo "==> Created: ${OUTFILE}"
echo "==> SHA256:  $(cat "${OUTFILE}.sha256")"
