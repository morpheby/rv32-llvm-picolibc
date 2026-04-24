#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) morpheby
#
# Update version references across the repository.
#
# Usage: update-version.sh <LLVM_VER> <PICOLIBC_VER> <RELEASE_NUM>
# Example: update-version.sh 21.1.8 1.8.11 1
#
# Version format: {llvm_ver}-{picolibc_ver}-{release_num}
#   e.g. 21.1.8-1.8.11-1  →  tag v21.1.8-1.8.11-1
#
# Updates:
#   - .github/workflows/build-release.yml  (LLVM_TAG, PICOLIBC_TAG, LLVM_VERSION)
#   - .github/workflows/ci.yml             (LLVM_TAG, PICOLIBC_TAG, LLVM_VERSION)
#   - package.json                          (version, xpack binaries URLs/filenames)
#   - README.md                             (version references in install and build sections)

set -e -o pipefail

LLVM_VER="${1:?Usage: $0 <LLVM_VER> <PICOLIBC_VER> <RELEASE_NUM>  (e.g. 21.1.8 1.8.11 1)}"
PICOLIBC_VER="${2:?Usage: $0 <LLVM_VER> <PICOLIBC_VER> <RELEASE_NUM>}"
RELEASE_NUM="${3:?Usage: $0 <LLVM_VER> <PICOLIBC_VER> <RELEASE_NUM>}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# sed -i differs between Linux (no backup arg) and macOS (requires empty string arg).
# Use a helper array for portability.
if [[ "$(uname)" == "Darwin" ]]; then
    SED_I=(sed -i '')
else
    SED_I=(sed -i)
fi

LLVM_MAJOR="${LLVM_VER%%.*}"
LLVM_TAG="llvmorg-${LLVM_VER}"
RELEASE_VERSION="${LLVM_VER}-${PICOLIBC_VER}-${RELEASE_NUM}"
XPACK_VERSION="${RELEASE_VERSION}.1"
TARNAME="rv32-llvm-picolibc-${RELEASE_VERSION}"
BASE_URL="https://github.com/morpheby/rv32-llvm-picolibc-xpack/releases/download/v${RELEASE_VERSION}"

echo "==> Updating versions to:"
echo "    LLVM:      ${LLVM_TAG}  (major: ${LLVM_MAJOR})"
echo "    picolibc:  ${PICOLIBC_VER}"
echo "    Release:   ${RELEASE_VERSION}"
echo "    xpack npm: ${XPACK_VERSION}"

# ── CI workflow files ─────────────────────────────────────────────────────────
for WF in build-release.yml ci.yml; do
    WF_PATH="${REPO_ROOT}/.github/workflows/${WF}"
    "${SED_I[@]}" \
        -e "s|LLVM_TAG: \"llvmorg-[^\"]*\"|LLVM_TAG: \"${LLVM_TAG}\"|" \
        -e "s|LLVM_VERSION: \"[^\"]*\"|LLVM_VERSION: \"${LLVM_MAJOR}\"|" \
        -e "s|PICOLIBC_TAG: \"[^\"]*\"|PICOLIBC_TAG: \"${PICOLIBC_VER}\"|" \
        "${WF_PATH}"
    echo "==> Updated ${WF}"
done

# ── package.json ──────────────────────────────────────────────────────────────
PKG="${REPO_ROOT}/package.json"
jq \
    --arg v   "${XPACK_VERSION}" \
    --arg fn  "${TARNAME}.tar.gz" \
    --arg url "${BASE_URL}" \
    '
      .version = $v |
      .xpack.binaries.baseUrl = $url |
      .xpack.binaries.platforms["darwin-arm64"].fileName = $fn |
      .xpack.binaries.platforms["darwin-x64"].fileName   = $fn |
      .xpack.binaries.platforms["linux-arm64"].fileName  = $fn |
      .xpack.binaries.platforms["linux-x64"].fileName    = $fn
    ' \
    "${PKG}" > "${PKG}.tmp"
mv "${PKG}.tmp" "${PKG}"
echo "==> Updated package.json"

# ── README.md ─────────────────────────────────────────────────────────────────
README="${REPO_ROOT}/README.md"

# LLVM major version heading: **LLVM 21** → **LLVM {major}**
"${SED_I[@]}" -E "s/\*\*LLVM [0-9]+\*\*/**LLVM ${LLVM_MAJOR}**/g" "${README}"

# xpack install snippet: "@morpheby/rv32-llvm-picolibc": "old" → new xpack version
"${SED_I[@]}" -E \
    "s|(\"@morpheby/rv32-llvm-picolibc\": )\"[^\"]*\"|\1\"${XPACK_VERSION}\"|g" \
    "${README}"

# llvm-project shallow clone branch
"${SED_I[@]}" -E \
    "s|(--branch )llvmorg-[^[:space:]]+( https://github.com/llvm/llvm-project)|\1${LLVM_TAG}\2|g" \
    "${README}"

# picolibc shallow clone branch (handles placeholder or a real version)
"${SED_I[@]}" -E \
    "s|(--branch )[^[:space:]]+( +https://github.com/picolibc/picolibc)|\1${PICOLIBC_VER}\2|g" \
    "${README}"

# patch apply reference
"${SED_I[@]}" -E \
    "s|(git apply [^ ]*patches/)llvmorg-[^[:space:]]+\.patch|\1${LLVM_TAG}.patch|g" \
    "${README}"

# VERSION= in package-dist invocation
"${SED_I[@]}" -E \
    "s|(VERSION=)[^ ]+( OUTDIR=)|\1${RELEASE_VERSION}\2|g" \
    "${README}"

echo "==> Updated README.md"
echo "==> Done. Version set to ${RELEASE_VERSION}."
