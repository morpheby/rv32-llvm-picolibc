# RISC-V Clang Toolchain for CH32V series MCUs — no exceptions, no RTTI
#
# Targets the rv32imafc_ilp32f multilib variant (hardware FPU, no C++
# exceptions, no RTTI).  Suitable for pure C firmware or C++ code that does
# not rely on exceptions or runtime type information.
#
# See clang-riscv-ch32v-exn-rtti.cmake for the variant with full C++ support.
# See clang-riscv-common.cmake for all user-facing cache variables.

set(_CH32_DEFAULT_MARCH "rv32imafc_zicsr_zifencei_xwchc")
set(_CH32_DEFAULT_MABI  "ilp32f")
set(_CH32_NO_EXCEPTIONS TRUE)
set(_CH32_NO_RTTI       TRUE)

include("${CMAKE_CURRENT_LIST_DIR}/clang-riscv-common.cmake")
