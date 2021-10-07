##
# @file
# @brief A CMake toolchain file for Clang
# @details Sets the following:
#          - platform       : x86_64-windows-msvc
#          - compiler       : Clang / Clang++
#          - linker         : lld (LLVM)
#          - std-library    : Default (MSVC)
#          - resource-comp. : rc (MSVC)
#

# Cross-compiling?
if (NOT CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "AMD64" OR NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set( CMAKE_SYSTEM_PROCESSOR "AMD64" )
    set( CMAKE_SYSTEM_NAME      "Windows" )
endif()
if (NOT CMAKE_SYSTEM_VERSION)
    set( CMAKE_SYSTEM_VERSION   "10.0.10240" )  # Windows 10 version 1507
endif()

# What MSVC runtime to use?
if (NOT DEFINED CMAKE_MSVC_RUNTIME_LIBRARY)
    set( CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" )  # dynamic runtime
endif()

# Fix for CMake versions before v3.23?
if (CMAKE_VERSION VERSION_LESS 3.23)
    set( CMAKE_C_LINKER_SUPPORTS_PDB   ON )
    set( CMAKE_CXX_LINKER_SUPPORTS_PDB ON )
endif()

set( CMAKE_C_COMPILER "clang" )
set( CMAKE_C_COMPILER_TARGET "x86_64-windows-msvc" )
set( CMAKE_CXX_COMPILER "clang++" )
set( CMAKE_CXX_COMPILER_TARGET "x86_64-windows-msvc" )
set( CMAKE_RC_COMPILER "rc" )

set( CMAKE_LINKER "lld-link" CACHE FILEPATH "Path to the linker." )
set( CMAKE_EXE_LINKER_FLAGS_INIT "-fuse-ld=lld-link" )
set( CMAKE_MODULE_LINKER_FLAGS_INIT "-fuse-ld=lld-link" )
set( CMAKE_SHARED_LINKER_FLAGS_INIT "-fuse-ld=lld-link" )
