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
#            * adjusting symbol-visibility to hide all symbols by default,
#            * setting the default postfixes for generated libraries,
#            * enabling generation of position-independent code, and
#            * enabling default warnings and errors.
#          * It determines the compiler-tag and stores it in a cache-variable
#            `ORGANIZATION_COMPILER_TAG`. (That variable should be helpful when providing hints to e.g.
#            `find_package` commands.)
#          * It adds the "Modules" subdirectory to the search-path for CMake modules.
#          * It sets the default install-prefix (path) that shall be used if the user does not
#            provide one.
#          * It sets the default install-prefix (path) for packaging if it is not set alrady.
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
set_default_library_postfixes()
enable_position_independent_code()
enable_default_warnings_and_errors()


# Store the default build-type in the CMake cache (if not already).
if (NOT DEFINED CMAKE_DEFAULT_BUILD_TYPE)
    set( CMAKE_DEFAULT_BUILD_TYPE Debug )  # Debug by default
endif()
set( CMAKE_DEFAULT_BUILD_TYPE ${CMAKE_DEFAULT_BUILD_TYPE}
     CACHE STRING
     "Choose the type of build to be used by default, options are: Debug, Release, RelWithDebInfo, MinSizeRel." )
unset( CMAKE_DEFAULT_BUILD_TYPE )  # Only keep cache variable.
set_property( CACHE CMAKE_DEFAULT_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo" "MinSizeRel" )
set_property( CACHE CMAKE_DEFAULT_BUILD_TYPE PROPERTY ADVANCED TRUE )


# Store the build-type / configuration-types in the CMake cache (if not already).
get_cmake_property( is_multi_config_generator GENERATOR_IS_MULTI_CONFIG )
if (is_multi_config_generator)
    if (NOT DEFINED CMAKE_CONFIGURATION_TYPES)
        set( CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo;MinSizeRel" )
    endif()
    set( CMAKE_CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES}
         CACHE STRING
         "Semicolon separated list of supported configuration types, only supports Debug, Release, MinSizeRel, and RelWithDebInfo, anything else will be ignored." )
    unset( CMAKE_CONFIGURATION_TYPES )  # Only keep cache variable.
    set_property( CACHE CMAKE_CONFIGURATION_TYPES PROPERTY ADVANCED TRUE )
else()
    if (NOT DEFINED CMAKE_BUILD_TYPE)
        set( CMAKE_BUILD_TYPE ${CMAKE_DEFAULT_BUILD_TYPE} )
    endif()
    set( CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}
         CACHE STRING
         "Choose the type of build, options are: Debug, Release, RelWithDebInfo, MinSizeRel." )
    unset( CMAKE_BUILD_TYPE )  # Only keep cache variable.
    set_property( CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo" "MinSizeRel" )
    set_property( CACHE CMAKE_BUILD_TYPE PROPERTY ADVANCED FALSE )
    # Workaround: Disable "CMAKE_DEFAULT_BUILD_TYPE" again to prevent errors.
    unset( CMAKE_DEFAULT_BUILD_TYPE CACHE )
endif()
unset( is_multi_config_generator )


# Set the default install-prefix (if the user did not set one explicitly).
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT OR NOT CMAKE_INSTALL_PREFIX)
    set( CMAKE_INSTALL_PREFIX "/opt/ORGANIZATION/${ORGANIZATION_COMPILER_TAG}"
         CACHE PATH "Install path prefix, prepended onto install directories." FORCE )
endif()
# Set the default install-prefix for packaging (if it is not set already).
if (NOT CMAKE_PACKAGING_INSTALL_PREFIX)
    set( CMAKE_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX} )
endif()
