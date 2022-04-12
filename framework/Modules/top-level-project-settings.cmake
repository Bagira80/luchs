##
# @file
# @note This file must be included (indirectly) after the top-level `project` command is called.
# @details This file contains different settings for the top-level CMakeLists.txt file.
#          * It loads the CTest module (and thereby creates a CMake option `BUILD_TESTING`).
#          * It sets the MSVC runtime to link against by default on Windows (if not set already).
#          * It sets up the compiler.
#          * It sets up options for enabling different sanitizers and a target `sanitizers` to
#            which other targets need to declare a dependency (via `target_link_libraries`) in
#            order to be compiled with sanitizers support.
#

# This file may only be called once and that should be after the top-level `project` command.
include_guard(GLOBAL)

# Verify that this file is included from the top-level CMakeLists.txt file.
if (NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    message( FATAL_ERROR "The current CMake script may only ever be called from the top-level CMakeLists.txt file!" )
endif()


# Enable support for CTest (and thereby automatically get the `BUILD_TESTING` option).
include( CTest )


# Are we building for Windows but have not already determined which MSVC runtime library to use by default?
if (CMAKE_SYSTEM_NAME STREQUAL "Windows" AND NOT DEFINED CMAKE_MSVC_RUNTIME_LIBRARY)
    # In that case use the dynamic MSVC runtime by default.
    set( CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" )
endif()


# Load and make some compiler-preparations.
include( "${CMAKE_CURRENT_LIST_DIR}/toolchain-settings.cmake" )


# Provide options and target for sanitizers.
include( Sanitizers )
