##
# @file
# @brief A CMake toolchain file for Clang-cl
# @details Sets the following:
#          - platform       : i686-windows-msvc
#          - compiler       : Clang-cl
#          - linker         : link (MSVC)
#          - std-library    : Default (MSVC)
#          - resource-comp. : rc (MSVC)
#

# Cross-compiling?
if (NOT CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "X86" OR NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set( CMAKE_SYSTEM_PROCESSOR "X86" )
    set( CMAKE_SYSTEM_NAME      "Windows" )
endif()
if (NOT CMAKE_SYSTEM_VERSION)
    set( CMAKE_SYSTEM_VERSION   "6.3.9600" )  # Windows 8.1
endif()

# What MSVC runtime to use?
if (NOT DEFINED CMAKE_MSVC_RUNTIME_LIBRARY)
    set( CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" )  # dynamic runtime
endif()

set( CMAKE_C_COMPILER "clang-cl" )
set( CMAKE_C_COMPILER_TARGET "i686-windows-msvc" )
set( CMAKE_CXX_COMPILER "clang-cl" )
set( CMAKE_CXX_COMPILER_TARGET "i686-windows-msvc" )
set( CMAKE_RC_COMPILER "rc" )

set( CMAKE_LINKER "link" CACHE FILEPATH "Path to the linker." )
