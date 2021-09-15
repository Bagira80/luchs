##
# @file
# @note This file should (automatically) be included in each CMakeLists.txt file after the
#       `project` command is called.
#
# @details This file contains different settings which are automatically applied after a new
#          project was set up.
#
#          * It updates the set of project version variables,
#            * by retrieving the current Git revision and providing it as version variable, and
#            * by retrieving the current build number from the environment and providing it as
#              version variable.
#


# Retrieve the Git revision.
execute_process( COMMAND git rev-parse HEAD
                 WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                 OUTPUT_VARIABLE project_revision
                 OUTPUT_STRIP_TRAILING_WHITESPACE
                 RESULT_VARIABLE result )
if (result)
    message( WARNING "Unable to retrieve Git revision for ${PROJECT_NAME}." )
    unset( project_revision )
endif()

# Update the project's version number with Git revision
# Note: The Git revision could not have become a part of the project's version number before the
#       call to `project`, because it is not all numeric and CMake would have complained about it.
# Note: For that same reason we are not appending the Git-revision to the project's version number
#       variable, as that would break CMake's ordered comparison for version numbers!
if (project_revision)
    #set( PROJECT_VERSION "${PROJECT_VERSION}-${project_revision}" )  # Would break CMake's version number comparison.
    #set( ${PROJECT_NAME}_VERSION ${PROJECT_VERSION} )                # Would break CMake's version number comparison.
    set( PROJECT_VERSION_REVISION "${project_revision}" )
    set( ${PROJECT_NAME}_VERSION_REVISION ${PROJECT_VERSION_REVISION} )
endif ()

# Set the project's build-version.
# Note: The CI/CD build-server might set this environment variable when building this project.
if (DEFINED ENV${CURRENT_BUILD_NUMBER})
    set( PROJECT_VERSION_BUILD_NUM "ENV${CURRENT_BUILD_NUMBER}" )
    set( ${PROJECT_NAME}_VERSION_BUILD_NUM "ENV${CURRENT_BUILD_NUMBER}" )
else()
    set( PROJECT_VERSION_BUILD_NUM "0" )
    set( ${PROJECT_NAME}_VERSION_BUILD_NUM "0" )
endif()
