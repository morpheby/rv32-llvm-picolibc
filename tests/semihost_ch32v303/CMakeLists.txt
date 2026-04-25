cmake_minimum_required(VERSION 3.20)
project(SemihostCH32V303Test C)

add_executable(semihost_ch32v303 main.c)

target_link_options(semihost_ch32v303 PRIVATE
    -T${CMAKE_CURRENT_SOURCE_DIR}/ch32v303.ld)
