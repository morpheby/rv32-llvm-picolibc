cmake_minimum_required(VERSION 3.20)
project(SemihostCH32V303Test C)

# Semihosted executable for CH32V303 (rv32imafc / ilp32f).
# Startup and I/O are provided by picolibc's semihosting layer
# (-lcrt0-semihost, -lsemihost) configured in the toolchain file.
# The linker script below defines the CH32V303 memory regions and delegates
# section layout to picolibc's standard picolibc.ld.
add_executable(semihost_ch32v303 main.c)

target_link_options(semihost_ch32v303 PRIVATE
    -T${CMAKE_CURRENT_SOURCE_DIR}/ch32v303.ld)
