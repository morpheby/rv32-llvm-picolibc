# rv32-llvm-picolibc-xpack

Binary xpack providing a RISC-V bare-metal sysroot built from:

- **LLVM 21** (compiler-rt builtins, libc++, libc++abi, libunwind)
- **picolibc 1.8.11** (C standard library)

Targets CH32V series MCUs with the `xwchc` vendor extension.

## Sysroot variants

Four multilib variants are active and selected automatically by clang based on
compiler flags (`-march`, `-mabi`, `-fno-exceptions`, `-fno-rtti`):

| Variant directory | `-march` | `-mabi` | Exceptions | RTTI |
|---|---|---|---|---|
| `rv32imafc-zicsr-zifencei-xwchc_ilp32f_exn_rtti` | rv32imafc_…_xwchc | ilp32f | ✓ | ✓ |
| `rv32imafc-zicsr-zifencei-xwchc_ilp32f` | rv32imafc_…_xwchc | ilp32f | — | — |
| `rv32imac-zicsr-zifencei-xwchc_ilp32_exn_rtti` | rv32imac_…_xwchc | ilp32 | ✓ | ✓ |
| `rv32imac-zicsr-zifencei-xwchc_ilp32` | rv32imac_…_xwchc | ilp32 | — | — |

compiler-rt and picolibc are also built for two additional `_exn`
(exceptions without RTTI) variants, but those are not included in the multilib
selection and have no libc++.

The `multilib.yaml` at the sysroot root drives automatic variant selection when
clang is invoked with `--sysroot=<dist>`.

## Install via xpm

```sh
npx xpm install @morpheby/rv32-llvm-picolibc
```

or add to `package.json`:

```json
"xpack": {
  "devDependencies": {
    "@morpheby/rv32-llvm-picolibc": "21.1.8-1.8.11-1.1"
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
      rv32imac-zicsr-zifencei-xwchc_ilp32_exn_rtti/
        …
      rv32imac-zicsr-zifencei-xwchc_ilp32/
        …
    cmake/
      clang-riscv-ch32v.cmake
      clang-riscv-ch32v-exn-rtti.cmake
      clang-riscv-ch32v20x.cmake
      clang-riscv-ch32v20x-exn-rtti.cmake
      clang-riscv-common.cmake
```

## Using in CMake

Four toolchain files are provided for common CH32V MCU families:

| Toolchain file | Target family | FPU | Exceptions + RTTI |
|---|---|---|---|
| `cmake/clang-riscv-ch32v.cmake` | CH32V (ilp32f) | ✓ | — |
| `cmake/clang-riscv-ch32v-exn-rtti.cmake` | CH32V (ilp32f) | ✓ | ✓ |
| `cmake/clang-riscv-ch32v20x.cmake` | CH32V20x (ilp32) | — | — |
| `cmake/clang-riscv-ch32v20x-exn-rtti.cmake` | CH32V20x (ilp32) | — | ✓ |

Pass the chosen file via `CMAKE_TOOLCHAIN_FILE`.  With the xpm installation:

```sh
cmake -DCMAKE_TOOLCHAIN_FILE=xpacks/@morpheby/rv32-llvm-picolibc/.content/cmake/clang-riscv-ch32v.cmake ...
```

`LLVM_TOOLCHAIN` (the sysroot path) is inferred automatically from the toolchain
file location — no extra configuration needed.

For C++ projects with exceptions, also link with `-lc++` to pull in libc++,
libc++abi, and libunwind (all statically bundled in `libc++.a`).

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

## Versioning

Release names follow the format:

```
rv32-llvm-picolibc-xpack-{llvm_ver}-{picolibc_ver}-{release_num}
```

For example: `rv32-llvm-picolibc-xpack-21.1.8-1.8.11-1` corresponds to tag
`v21.1.8-1.8.11-1` and xpack npm version `21.1.8-1.8.11-1.1`.

## Releasing a new version

### Option A — via GitHub Actions (recommended)

Trigger the **Bump version and tag** workflow manually from the Actions tab:

1. Go to **Actions → Bump version and tag → Run workflow**.
2. Enter the LLVM version (e.g. `21.1.8`), picolibc version (e.g. `1.8.11`),
   and release number (e.g. `1`).
3. The workflow updates all version references in the repo, commits the changes,
   creates an annotated tag, and pushes both to `main`.
4. The pushed tag triggers `build-release.yml`, which builds the sysroot, creates
   the GitHub release asset, and automatically updates `package.json` with the
   correct SHA-256.

### Option B — locally

```sh
# 1. Update version references everywhere
bash scripts/update-version.sh 21.1.8 1.8.11 1

# 2. Commit the changes
git add -A
git commit -m "chore: bump version to 21.1.8-1.8.11-1"

# 3. Create the annotated tag
bash scripts/tag-release.sh 21.1.8 1.8.11 1

# 4. Push commit + tag
git push origin main --follow-tags
```

Update the patch file under `patches/` if the LLVM version changed.

## Building locally

Requires: LLVM 21 (clang, clang++, lld, llvm-ar, llvm-nm, llvm-ranlib),
cmake, ninja, meson.

```sh
# 1. Clone sources
git clone --depth=1 --branch main https://github.com/llvm/llvm-project.git workspace/llvm-project
git clone --depth=1 --branch main https://github.com/picolibc/picolibc.git  workspace/picolibc

# 2. Apply patches (if any)
cd workspace/llvm-project
git apply ../../patches/llvmorg-21.1.8.patch
cd ../..

# 3. Set up environment
export XPACK_DIR="$(pwd)"   # root of this repository checkout
export WORKSPACE="$(pwd)/workspace"
export DIST_DIR="$WORKSPACE/rv32-llvm-picolibc"
export PICOLIBC_CROSS_FILES_DIR="$XPACK_DIR/picolibc-cross-files"

# 4. Build in order
(cd workspace/llvm-project &&  "$XPACK_DIR/scripts/build-compiler_rt.sh")
(cd workspace/picolibc      && "$XPACK_DIR/scripts/build-picolibc.sh")
(cd workspace/llvm-project && "$XPACK_DIR/scripts/build-libcxx.sh")

# 5. Package
VERSION=21.1.8-1.8.11-1 OUTDIR=. "$XPACK_DIR/scripts/package-dist.sh"
```
