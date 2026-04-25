# RISC-V Clang Toolchain for CH32V303 — semihosting variant
#
# Targets the rv32imafc_ilp32f multilib variant with hardware FPU, routing
# all I/O through the RISC-V semihosting ABI to the host debugger or QEMU.
#
# See clang-riscv-ch32v.cmake for the standard firmware variant and
# clang-riscv-common.cmake for all user-facing cache variables.

set(_CH32_DEFAULT_MARCH "rv32imafc_zicsr_zifencei_xwchc")
set(_CH32_DEFAULT_MABI  "ilp32f")
set(_CH32_NO_EXCEPTIONS TRUE)
set(_CH32_NO_RTTI       TRUE)

set(_CH32_LINKER_LIBS "-lcrt0-semihost -lsemihost")

include("${CMAKE_CURRENT_LIST_DIR}/clang-riscv-common.cmake")
