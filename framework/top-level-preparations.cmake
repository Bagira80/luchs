##
# @file
# @note This file should be included from the top-level CMakeLists.txt file before the `project`
#       command is called.
#
# @details This file contains different preparations for the top-level CMakeLists.txt file.
#
#          * It adds the "Modules" subdirectory to the search-path for CMake modules.
#          * It adds the "Modules-<cmake-version>" subdirectory to the search-path for CMake modules.
#          * It sets and stores some important CMake cache variables.
#

# This file may only be called once and that should be from the top-level CMakeLists.txt file!
include_guard(GLOBAL)

# Verify that this file is included from the top-level CMakeLists.txt file.
if (NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    message( FATAL_ERROR "The current \"luchs\" CMake script may only ever be called from the top-level CMakeLists.txt file!" )
endif()


# A convenience variable pointing to the directory containing the current file.
set( LUCHS_CMAKE_SCRIPTS_DIR "${CMAKE_CURRENT_LIST_DIR}" )
# A convenience variable pointing to the directory containing file and script templates.
set( LUCHS_TEMPLATES_DIR "${LUCHS_CMAKE_SCRIPTS_DIR}/templates" )
# A convenience variable pointing to the workspace directory for luchs.
set( LUCHS_BINARY_DIR "${CMAKE_BINARY_DIR}/_luchs" )

# Put the "Modules" subdirectory (of the current directory) into the modules search-path.
list( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules" )
# Put an additional "Modules-<cmake-version>" subdirectory into the modules search-path (if any).
# Note: These might back-port functionality from newer CMake versions.
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/Modules-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}")
    list( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Modules-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" )
endif()


# Enable FOLDERS property on targets for better grouping in IDEs.
set_property( GLOBAL PROPERTY USE_FOLDERS ON )


# Always generate the compilation database, which will aid other tools (like IDEs).
set( CMAKE_EXPORT_COMPILE_COMMANDS TRUE
     CACHE BOOL "Enable/Disable output of compile commands during generation." FORCE )


# Store the default build-type in the CMake cache (if not already).
if (NOT DEFINED CMAKE_DEFAULT_BUILD_TYPE)
    set( CMAKE_DEFAULT_BUILD_TYPE Debug )  # Debug by default
endif()
set( CMAKE_DEFAULT_BUILD_TYPE ${CMAKE_DEFAULT_BUILD_TYPE} CACHE STRING
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
    set( CMAKE_CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES} CACHE STRING
         "Semicolon separated list of supported configuration types, only supports Debug, Release, MinSizeRel, and RelWithDebInfo, anything else will be ignored." )
    unset( CMAKE_CONFIGURATION_TYPES )  # Only keep cache variable.
    set_property( CACHE CMAKE_CONFIGURATION_TYPES PROPERTY ADVANCED TRUE )
else()
    if (NOT DEFINED CMAKE_BUILD_TYPE)
        set( CMAKE_BUILD_TYPE ${CMAKE_DEFAULT_BUILD_TYPE} )
    endif()
    set( CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING
         "Choose the type of build, options are: Debug, Release, RelWithDebInfo, MinSizeRel." )
    unset( CMAKE_BUILD_TYPE )  # Only keep cache variable.
    set_property( CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo" "MinSizeRel" )
    set_property( CACHE CMAKE_BUILD_TYPE PROPERTY ADVANCED FALSE )
endif()
unset( is_multi_config_generator )
# Workaround, when not using "Ninja Multi-Config" generator.
if (NOT "${CMAKE_GENERATOR}" STREQUAL "Ninja Multi-Config")
    unset( CMAKE_DEFAULT_BUILD_TYPE CACHE )  # Disable again to prevent CMake errors.
endif()
