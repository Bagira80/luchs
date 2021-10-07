##
# @file
# @brief A CMake toolchain file for Clang
# @details Sets the following:
#          - platform    : x86_64-linux-gnu
#          - compiler    : Clang / Clang++ version 12
#          - linker      : LLD (LLVM linker)
#          - std-library : libc++ (LLVM)
#

# Cross-compiling?
if (NOT CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "x86_64" OR NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    set( CMAKE_SYSTEM_PROCESSOR "x86_64" )
    set( CMAKE_SYSTEM_NAME      "Linux" )
    # Sadly, we currently do not know which Linux version we are targeting!
    if (NOT DEFINED CMAKE_SYSTEM_VERSION)
        message( WARNING "CMAKE_SYSTEM_VERSION cannot be set automatically! Please provide one via command-line." )
    endif()
endif()

set( CMAKE_C_COMPILER "clang-12" )
set( CMAKE_C_COMPILER_TARGET "x86_64-linux-gnu" )
set( CMAKE_CXX_COMPILER "clang++-12" )
set( CMAKE_CXX_COMPILER_TARGET "x86_64-linux-gnu" )

set( CMAKE_LINKER "ld.lld-12" CACHE FILEPATH "Default linker" )
set( CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld-12" )
set( CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld-12" )
set( CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld-12" )

set( CMAKE_CXX_FLAGS_INIT "-stdlib=libc++" )
