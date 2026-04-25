cmake_minimum_required(VERSION 3.20)
project(SemihostCxxTest CXX)

add_compile_options(
    -D_PICOLIBC_PRINTF='f'
    -D_PICOLIBC_SCANF='m'
)

add_executable(semihost_cxx main.cpp)
target_link_options(semihost_cxx PRIVATE
    -lcrt0-semihost -lsemihost
    -Wl,--defsym=vfprintf=__f_vfprintf
    -Wl,--defsym=vfscanf=__m_vfscanf
    -T${CMAKE_CURRENT_SOURCE_DIR}/rv32.ld)
