# RISC-V Clang Toolchain for CH32V series MCUs — exceptions + RTTI
#
# Targets the rv32imafc_ilp32f_exn_rtti multilib variant (hardware FPU,
# C++ exceptions enabled, RTTI enabled).  Use this toolchain for C++ projects
# that rely on std::exception, dynamic_cast, typeid, or other features that
# require exception-handling tables or RTTI.
#
# Linker note: add -lc++ to your project's link step to pull in libc++,
# libc++abi and libunwind (all statically bundled in the sysroot's libc++.a).
#
# See clang-riscv-ch32v.cmake for the leaner no-exceptions / no-RTTI variant.
# See clang-riscv-common.cmake for all user-facing cache variables.

set(_CH32_DEFAULT_MARCH "rv32imafc_zicsr_zifencei_xwchc")
set(_CH32_DEFAULT_MABI  "ilp32f")
set(_CH32_NO_EXCEPTIONS FALSE)
set(_CH32_NO_RTTI       FALSE)

include("${CMAKE_CURRENT_LIST_DIR}/clang-riscv-common.cmake")
