# rv32-llvm-picolibc-xpack

Binary xpack providing a RISC-V bare-metal sysroot built from:

- **LLVM 21** (compiler-rt builtins, libc++, libc++abi, libunwind)
- **picolibc** (C standard library)

Targets CH32V series MCUs with the `xwchc` vendor extension.

## Sysroot variants

| Variant directory | `-march` | `-mabi` | Exceptions | RTTI |
|---|---|---|---|---|
| `rv32imafc-zicsr-zifencei-xwchc_ilp32f_exn_rtti` | rv32imafc_…_xwchc | ilp32f | ✓ | ✓ |
| `rv32imafc-zicsr-zifencei-xwchc_ilp32f_exn` | rv32imafc_…_xwchc | ilp32f | ✓ | — |
| `rv32imafc-zicsr-zifencei-xwchc_ilp32f` | rv32imafc_…_xwchc | ilp32f | — | — |
| `rv32imac-zicsr-zifencei-xwchc_ilp32_exn_rtti` | rv32imac_…_xwchc | ilp32 | ✓ | ✓ |
| `rv32imac-zicsr-zifencei-xwchc_ilp32_exn` | rv32imac_…_xwchc | ilp32 | ✓ | — |
| `rv32imac-zicsr-zifencei-xwchc_ilp32` | rv32imac_…_xwchc | ilp32 | — | — |

compiler-rt and picolibc are built for all 6 variants.
libc++ / libc++abi / libunwind are only built for the 4 active multilib variants
(RTTI is required for exception support in libc++, so the `_exn` variants without
RTTI do not include libc++).

The `multilib.yaml` at the sysroot root enables automatic variant selection when
clang is invoked with `--sysroot=<.content/dist>`.

## Install via xpm

```sh
npx xpm install @morpheby/rv32-llvm-picolibc
```

or add to `package.json`:

```json
"xpack": {
  "devDependencies": {
    "@morpheby/rv32-llvm-picolibc": "21.1.8-1.1"
  }
}
```

## Sysroot layout after install

```
xpacks/@morpheby/rv32-llvm-picolibc/
  .content/
    dist/
      multilib.yaml
      rv32imafc-zicsr-zifencei-xwchc_ilp32f_exn_rtti/
        include/  ← compiler-rt, picolibc, libc++ headers
        lib/      ← libclang_rt.builtins.a, libc.a, libc++.a, …
      rv32imafc-zicsr-zifencei-xwchc_ilp32f/
        …
      …
```

## Using in CMake

```cmake
-DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/riscv-llvm-ch32v.cmake
```

The toolchain file references the sysroot automatically from the xpack install
path.

## License and acknowledgments

This project is licensed under the **Apache License, Version 2.0** — see
[LICENSE](LICENSE) for the full text.

Portions of this project are derived from or inspired by the
[LLVM Embedded Toolchain for Arm](https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm)
project (© 2020–2023 Arm Limited and affiliates, Apache-2.0).  Specifically:

- `multilib.yaml` — structure and comments adapted from `multilib.yaml.in` in
  that repository.
- `picolibc-cross-files/*.txt` — cross-file format and property conventions
  follow those established in the same project.
- `scripts/build-*.sh` — CMake/meson invocation patterns and staged-install
  technique are derived from its build system.

See [NOTICE](NOTICE) for the full attribution.

---

## Releasing a new version

1. Update pinned source versions in `.github/workflows/build-release.yml`
   (`LLVM_TAG`, `PICOLIBC_TAG`, `LLVM_VERSION`) and update the patch file if
   required.
2. Commit changes to `main`.
3. Push a version tag:
   ```sh
   git tag v21.1.8-1
   git push origin v21.1.8-1
   ```
4. The `build-release.yml` workflow builds the sysroot, creates the GitHub
   release asset, and automatically updates `package.json` with the correct
   SHA-256.

## Building locally

Requires: LLVM 21 (clang, lld, llvm-ar, llvm-nm, llvm-ranlib), cmake, ninja, meson.

```sh
# 1. Clone sources
git clone --depth=1 --branch llvmorg-21.1.8 https://github.com/llvm/llvm-project.git workspace/llvm-project
git clone --depth=1 --branch <picolibc-tag>  https://github.com/picolibc/picolibc.git  workspace/picolibc

# 2. Apply patches
cd workspace/llvm-project
git apply ../../patches/llvmorg-21.1.8.patch
cd ../..

# 3. Copy cross-files and multilib.yaml into place
cp picolibc-cross-files/*.txt workspace/picolibc/rv-multilib-scripts/
cp multilib.yaml workspace/llvm-project/

# 4. Build in order
export WORKSPACE="$(pwd)/workspace"
export DIST_DIR="$WORKSPACE/rv32-llvm-picolibc"
export INSTALL_PREFIX="/usr/local/llvm-riscv"
export PICOLIBC_PREFIX="/usr/local"
export PICOLIBC_CROSS_FILES_DIR="$(pwd)/picolibc-cross-files"

(cd workspace/llvm-project && bash ../../scripts/build-compiler_rt.sh)
(cd workspace/picolibc      && bash ../../scripts/build-picolibc.sh)
(cd workspace/llvm-project && bash ../../scripts/build-libcxx.sh)

# 5. Package
VERSION=21.1.8-1 OUTDIR=. bash scripts/package-dist.sh
```
