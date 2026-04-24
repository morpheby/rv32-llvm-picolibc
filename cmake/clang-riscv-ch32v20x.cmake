# RISC-V Clang Toolchain for CH32V20x MCUs (no hardware FPU)
#
# This toolchain file configures CMake for cross-compiling CH32V20x firmware
# using the native clang toolchain.  CH32V20x devices implement the rv32imac
# ISA (no 'f' extension) and use the ilp32 ABI.
#
# Cache variables:
#   LLVM_TOOLCHAIN - sysroot for the picolibc+LLVM bundle; the toolchain
#                    uses multilib so no per-arch subdir is needed
#   TOOLCHAIN_PATH - path to clang bin/ directory (empty = use PATH)
#   CH32_MARCH     - RISC-V march string (default: rv32imac_zicsr_zifencei_xwchc for CH32V203)
#   CH32_MABI      - RISC-V ABI (default: ilp32)

cmake_minimum_required(VERSION 3.20)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# ----- Toolchain prefix -----
set(CROSS_COMPILE "riscv-unknown-none-elf-" CACHE STRING "Toolchain prefix")

# ----- Local developer config (LLVM_TOOLCHAIN etc.) -----
include("${CMAKE_CURRENT_LIST_DIR}/../local-config.cmake" OPTIONAL)

# ----- Toolchain path detection -----
if(NOT DEFINED TOOLCHAIN_PATH)
    # Assume clang is on PATH (set up by activate.sh / activate.ps1)
    set(TOOLCHAIN_PATH "" CACHE PATH "Toolchain bin/ directory (empty = use PATH)")
endif()

if(TOOLCHAIN_PATH)
    set(_PREFIX "${TOOLCHAIN_PATH}/")
else()
    set(_PREFIX "")
endif()

# On Windows, full-path compiler references need the .exe suffix.
if(CMAKE_HOST_WIN32 AND TOOLCHAIN_PATH)
    set(_EXE ".exe")
else()
    set(_EXE "")
endif()

# ----- Compilers -----
set(CMAKE_C_COMPILER   "${_PREFIX}clang${_EXE}"        CACHE FILEPATH "" FORCE)
set(CMAKE_CXX_COMPILER "${_PREFIX}clang++${_EXE}"      CACHE FILEPATH "" FORCE)
set(CMAKE_ASM_COMPILER "${_PREFIX}clang${_EXE}"        CACHE FILEPATH "" FORCE)
set(CMAKE_OBJCOPY      "${_PREFIX}llvm-objcopy${_EXE}" CACHE FILEPATH "" FORCE)
set(CMAKE_OBJDUMP      "${_PREFIX}llvm-objdump${_EXE}" CACHE FILEPATH "" FORCE)
set(CMAKE_SIZE_UTIL    "${_PREFIX}llvm-size${_EXE}"    CACHE FILEPATH "" FORCE)
set(CMAKE_AR           "${_PREFIX}llvm-ar${_EXE}"      CACHE FILEPATH "" FORCE)
set(CMAKE_RANLIB       "${_PREFIX}llvm-ranlib${_EXE}"  CACHE FILEPATH "" FORCE)

# ----- Architecture flags -----
# CH32V20x: rv32imac — no hardware FPU, integer-only ABI (ilp32)
set(CH32_MARCH "rv32imac_zicsr_zifencei_xwchc" CACHE STRING "RISC-V -march value")
set(CH32_MABI  "ilp32"                          CACHE STRING "RISC-V -mabi value")

set(ARCH_FLAGS
    --target=riscv32-unknown-none-elf
    -march=${CH32_MARCH}
    -mabi=${CH32_MABI}
    -msmall-data-limit=8
    -msave-restore
)

string(JOIN " " ARCH_FLAGS_STR ${ARCH_FLAGS})

# ----- Sysroot (from LLVM_TOOLCHAIN root) -----
# The toolchain uses multilib; clang selects the correct variant from -march/-mabi.
if(NOT LLVM_TOOLCHAIN)
    message(FATAL_ERROR
        "LLVM_TOOLCHAIN is not set. Copy cmake/local-config.cmake.example to "
        "cmake/local-config.cmake and set the path, or run doctor.ps1 / doctor.sh.")
endif()
if(NOT EXISTS "${LLVM_TOOLCHAIN}")
    message(FATAL_ERROR
        "LLVM_TOOLCHAIN directory not found: ${LLVM_TOOLCHAIN}\n"
        "Check LLVM_TOOLCHAIN in cmake/local-config.cmake.")
endif()

# ----- Common compile flags -----
set(COMMON_FLAGS
    --sysroot=${LLVM_TOOLCHAIN}
    ${ARCH_FLAGS}
    -Os -ffast-math
    -Wall
    -fmessage-length=0
    -fsigned-char
    -ffunction-sections
    -fdata-sections
    -fno-common
    -flto=full
    -fvirtual-function-elimination
    -fwhole-program-vtables
    -fno-exceptions
    -fno-rtti
    -fcolor-diagnostics
    -D_PICOLIBC_PRINTF='f'
    -D_PICOLIBC_SCANF='m'
    -D_GNU_SOURCE=1
    -fconstexpr-steps=134217728
)

string(JOIN " " COMMON_FLAGS_STR ${COMMON_FLAGS})

set(CMAKE_C_FLAGS_INIT           "-std=gnu23 ${COMMON_FLAGS_STR}")
set(CMAKE_CXX_FLAGS_INIT         "${COMMON_FLAGS_STR} -std=gnu++20 -fno-threadsafe-statics -fno-use-cxa-atexit -fpermissive")
set(CMAKE_ASM_FLAGS_INIT         "${ARCH_FLAGS_STR} --target=riscv32-unknown-none-elf -x assembler-with-cpp")

# ----- Linker flags -----
set(CMAKE_EXE_LINKER_FLAGS_INIT  "--sysroot=${LLVM_TOOLCHAIN} ${ARCH_FLAGS_STR} -Wl,--gc-sections -lch32_hal -lcrt0 -lcrt0-inittls -Wl,--defsym=vfprintf=__f_vfprintf -Wl,--defsym=vfscanf=__m_vfscanf -nostartfiles -Lthird_party/ch32_hal")

set(CMAKE_C_USING_LINKER_LLD "-fuse-ld=lld")
set(CMAKE_CXX_USING_LINKER_LLD "-fuse-ld=lld")
set(CMAKE_LINKER_TYPE LLD)

# ----- Debug / Release flag overrides -----
# The project always uses -Os; debug adds symbols only.
set(CMAKE_C_FLAGS_DEBUG           "-ggdb2" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_DEBUG         "-ggdb2" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE         ""       CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE       ""       CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_MINSIZEREL      ""       CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_MINSIZEREL    ""       CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELWITHDEBINFO  "-ggdb2" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-ggdb2" CACHE STRING "" FORCE)

# ----- Search paths -----
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
