##
# @file
# @note This file must be included (indirectly) after the top-level `project` command is called.
# @details This file makes toolchain-specific settings that it reads from the scripts in the
#          subdirectory `ToolchainSettings`, which is located in the same directory as this file.
#

# This file may only be called once and that should be after the top-level `project` command.
include_guard(GLOBAL)

# Verify that this file is included (indirectly) from the top-level CMakeLists.txt file.
if (NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    message( FATAL_ERROR "The current CMake script may only ever be called from the top-level CMakeLists.txt file!" )
endif()
