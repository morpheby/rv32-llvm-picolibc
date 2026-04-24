#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright (c) morpheby
#
# Create an annotated git tag for a release.
#
# Usage: tag-release.sh <LLVM_VER> <PICOLIBC_VER> <RELEASE_NUM>
# Example: tag-release.sh 21.1.8 1.8.11 1
#
# Creates annotated tag: v{llvm_ver}-{picolibc_ver}-{release_num}
#   e.g. v21.1.8-1.8.11-1
#
# The tag annotation records the component versions that make up the release.

set -e -o pipefail

LLVM_VER="${1:?Usage: $0 <LLVM_VER> <PICOLIBC_VER> <RELEASE_NUM>  (e.g. 21.1.8 1.8.11 1)}"
PICOLIBC_VER="${2:?Usage: $0 <LLVM_VER> <PICOLIBC_VER> <RELEASE_NUM>}"
RELEASE_NUM="${3:?Usage: $0 <LLVM_VER> <PICOLIBC_VER> <RELEASE_NUM>}"

RELEASE_VERSION="${LLVM_VER}-${PICOLIBC_VER}-${RELEASE_NUM}"
TAG_NAME="v${RELEASE_VERSION}"

TAG_MESSAGE="rv32-llvm-picolibc-xpack-${RELEASE_VERSION}

LLVM:      llvmorg-${LLVM_VER}
picolibc:  ${PICOLIBC_VER}
Release:   ${RELEASE_NUM}"

if git rev-parse "${TAG_NAME}" >/dev/null 2>&1; then
    echo "ERROR: Tag ${TAG_NAME} already exists." >&2
    exit 1
fi

git tag -a "${TAG_NAME}" -m "${TAG_MESSAGE}"
echo "==> Created annotated tag: ${TAG_NAME}"
echo "==> Push with: git push origin ${TAG_NAME}"
