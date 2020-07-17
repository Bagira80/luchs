##
# @file
# @note This file should be (automatically) included in each CMakeLists.txt file after the
#       `project` command is called.
#
# @details This file contains different settings which are automatically applied after a new
#          project was set up.
#
#          * It updates the set of project version variables,
#            * by retrieving the current Git revision and providing it as version variable, and
#            * by retrieving the current build number from the environment and providing it as
#              version variable.
#          * It generates a source-file containing the build-configuration of the current module.
#          * It provides some global settings for the top-level CMakeLists.txt file:
#            * setting the default suffixes/prefixes for generated binaries,
#            * (optionally) enabling link-time optimization
#


# Retrieve the Git revision.
execute_process( COMMAND git rev-parse HEAD
                 WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                 OUTPUT_VARIABLE project_revision
                 OUTPUT_STRIP_TRAILING_WHITESPACE
                 RESULT_VARIABLE result )
if (result)
    message( WARNING "Unable to retrieve Git revision for ${PROJECT_NAME}." )
endif()

# Update the project's version number with Git revision
# Note: The Git revision could not have become a part of the project's version number before the
#       call to `project`, because it is not all numeric and CMake would have complained about it.
if (project_revision)
    #set( PROJECT_VERSION "${PROJECT_VERSION}-${project_revision}" )
    #set( ${PROJECT_NAME}_VERSION ${PROJECT_VERSION} )
    set( PROJECT_VERSION_REVISION "${project_revision}" )
    set( ${PROJECT_NAME}_VERSION_REVISION ${PROJECT_VERSION_REVISION} )
endif ()

# Set the project's build-version (if provided via environment).
if (DEFINED ENV${CURRENT_BUILD_NUMBER})
    set( PROJECT_BUILD_VERSION "ENV${CURRENT_BUILD_NUMBER}" )
    set( ${PROJECT_NAME}_BUILD_VERSION "ENV${CURRENT_BUILD_NUMBER}" )
endif()


# Generate a source-file containing the build-configuration of the current module.
include( ex_configure_file )
ex_configure_file( "${ORGANIZATION_TEMPLATES_DIR}/Module_BuildConfig.cpp.in"
                   "src/Module_BuildConfig_$<CONFIG>.cpp" )


# Settings only for top-level CMakeLists.txt file.
if (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set_default_binary_suffixes_and_prefixes()

    # Enable link-time optimization globally?
    if (ENABLE_LTO)
        enable_link_time_optimization()
    endif()
endif()
