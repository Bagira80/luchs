##
# @file
# @note This file should be included in the top-level CMakeLists.txt file before the `project`
#       command is called.
#
# @details This file contains different preparations for the top-level CMakeLists.txt file.
#
#          * It enables common required build settings, the minimal C++ standard and default
#            warnings and errors.
#          * It determines the compiler-tag and stores it in a cache-variable
#            `ORGANIZATION_COMPILER_TAG`. (That variable should be helpful when providing hints to e.g.
#            `find_package` commands.)
#          * It adds the "Modules" subdirectory to the search-path for CMake modules.
#          * It also points the `CMAKE_PROJECT_INCLUDE_BEFORE` variable to the file which contains
#            several actions that should be run prior to any `project` command call and likewise
#            points the `CMAKE_PROJECT_INCLUDE` variable to the file which contains several actions
#            that should be run after any `project` command call.
#          * Temporarily (until a similar feature is provided by CMake directly), it also provides
#            two macros for backing up and later restoring these variables.
#            These are needed when using FetchContent.
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


# Load the helper-functions for determining/storing the compiler-tag
# and store that tag in the CMake-cache as `ORGANIZATION_COMPILER_TAG`.
include( "${CMAKE_CURRENT_LIST_DIR}/compiler-tag.cmake" )
store_compiler_tag( "ORGANIZATION_COMPILER_TAG" )


# Load and make some compiler-preparations.
include( "${CMAKE_CURRENT_LIST_DIR}/compiler-preparations.cmake" )
set_required_build_settings()
set_minimum_required_cxx_standard()
enable_default_warnings_and_errors()


# Location of a file which will be loaded automatically before processing any new project and
# which contains common actions that will be processed. Amongst other things it will load a
# project-specific file with additional information for the project command.
set( CMAKE_PROJECT_INCLUDE_BEFORE "${CMAKE_CURRENT_LIST_DIR}/Modules/common-project-pre-actions.cmake" )

# Location of a file which will be loaded automatically after processing any new project and
# which contains common actions that will be processed. Amongst other things it will load a
# project-specific file with additional information for the project command.
set( CMAKE_PROJECT_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/Modules/common-project-post-actions.cmake" )


# Temporarily unsets the two variables CMAKE_PROJECT_INCLUDE_BEFORE and CMAKE_PROJECT_INCLUDE.
# Note: This should only be used until there is something similar implemented in CMake itself.
macro( backup_project_vars )
    set( TEMP_BACKUP_CMAKE_PROJECT_INCLUDE_BEFORE "${CMAKE_PROJECT_INCLUDE_BEFORE}" )
    set( TEMP_BACKUP_CMAKE_PROJECT_INCLUDE "${CMAKE_PROJECT_INCLUDE}" )
    unset( CMAKE_PROJECT_INCLUDE_BEFORE )
    unset( CMAKE_PROJECT_INCLUDE )
endmacro()

# Restore the temporarily unset two variables CMAKE_PROJECT_INCLUDE_BEFORE and CMAKE_PROJECT_INCLUDE.
# Note: This should only be used until there is something similar implemented in CMake itself.
macro( restore_project_vars )
    set( CMAKE_PROJECT_INCLUDE_BEFORE "${TEMP_BACKUP_CMAKE_PROJECT_INCLUDE_BEFORE}" )
    set( CMAKE_PROJECT_INCLUDE "${TEMP_BACKUP_CMAKE_PROJECT_INCLUDE}" )
    unset( TEMP_BACKUP_CMAKE_PROJECT_INCLUDE_BEFORE )
    unset( TEMP_BACKUP_CMAKE_PROJECT_INCLUDE )
endmacro()

