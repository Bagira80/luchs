##
# @file
# @note This file should be included in the top-level CMakeLists.txt file before the `project`
#       command is called.
#
# @details This file contains different preparations for the top-level CMakeLists.txt file.
#
#          * It sets up the compiler,
#            * enabling some common required build settings,
#            * setting the minimal supported C++ standard,
#            * adjusting symbol-visibility to hide all symbols by default, and
#            * enabling default warnings and errors.
#          * It determines the compiler-tag and stores it in a cache-variable
#            `ORGANIZATION_COMPILER_TAG`. (That variable should be helpful when providing hints to e.g.
#            `find_package` commands.)
#          * It adds the "Modules" subdirectory to the search-path for CMake modules.
#

# This file may only be called once and that should be from the top-level CMakeLists.txt file!
include_guard(GLOBAL)

# Variable to indicate that this file has been called already in the current scope.
set( ALREADY_DONE_TOP_LEVEL_PREPARATIONS TRUE )


# A convenience variable pointing to the directory containing the current file.
set( ORGANIZATION_CMAKE_SCRIPTS_DIR "${CMAKE_CURRENT_LIST_DIR}" )
# A convenience variable pointing to the directory containing file and script templates.
set( ORGANIZATION_TEMPLATES_DIR "${ORGANIZATION_CMAKE_SCRIPTS_DIR}/templates" )
# Put the "Modules" subdirectory (of the current directory) into the modules search-path.
list( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules" )


# Change some CMake defaults for C and C++.
set( CMAKE_USER_MAKE_RULES_OVERRIDE_C   "${CMAKE_CURRENT_LIST_DIR}/override-cmake-defaults-for-cc.cmake" )
set( CMAKE_USER_MAKE_RULES_OVERRIDE_CXX "${CMAKE_CURRENT_LIST_DIR}/override-cmake-defaults-for-cxx.cmake" )


# Always generate the compilation database, which will aid other tools.
set( CMAKE_EXPORT_COMPILE_COMMANDS TRUE
     CACHE BOOL "Enable/Disable output of compile commands during generation." FORCE )


# Load the helper-functions for determining/storing the compiler-tag
# and store that tag in the CMake-cache as `ORGANIZATION_COMPILER_TAG`.
include( "${CMAKE_CURRENT_LIST_DIR}/compiler-tag.cmake" )
store_compiler_tag( "ORGANIZATION_COMPILER_TAG" )


# Load and make some compiler-preparations.
include( "${CMAKE_CURRENT_LIST_DIR}/compiler-preparations.cmake" )
set_required_build_settings()
set_minimum_required_cxx_standard()
set_default_visibility_to_hidden()
enable_default_warnings_and_errors()


