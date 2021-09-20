##
# @file
# @note This file must be included (indirectly) after the top-level `project` command is called.
# @details This file contains different settings for the top-level CMakeLists.txt file.
#          * It loads the CTest module (and thereby creates a CMake option `BUILD_TESTING`).
#          * It sets up the compiler.
#

# This file may only be called once and that should be after the top-level `project` command.
include_guard(GLOBAL)

# Verify that this file is included from the top-level CMakeLists.txt file.
if (NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    message( FATAL_ERROR "The current CMake script may only ever be called from the top-level CMakeLists.txt file!" )
endif()


# Enable support for CTest (and thereby automatically get the `BUILD_TESTING` option).
include( CTest )


# Load and make some compiler-preparations.
include( "${CMAKE_CURRENT_LIST_DIR}/toolchain-settings.cmake" )
