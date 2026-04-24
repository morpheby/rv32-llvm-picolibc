cmake_minimum_required(VERSION 3.20)
project(HelloWorldTest C)

# Build as a static library (compile + archive, no link step).
# With -flto=full the compiler emits LLVM bitcode objects, which llvm-ar
# archives normally.  Bare-metal linking requires a project-specific linker
# script and startup code; this test validates the compiler and sysroot only.
add_library(hello_world STATIC main.c)
