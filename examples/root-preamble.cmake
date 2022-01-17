##
# @file
# @note This file should (automatically) be included at least in the top-level (aka root-)
#       CMakeLists.txt file, directly after the call to the `cmake_minimum_required` command.
#
# @details Contains the logic to load the _luchs_ CMake support framework and to make the required
#          preparations for the top-level (aka root-)CMakeLists.txt.
#


# Only do anything if this is the top-level CMakeLists.txt file.
if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    include( FetchContent )
    # Never accept the following variables from the call to CMake:
    unset( LOCAL_PATH )
    unset( GIT_REPOSITORY )
    unset( GIT_TAG )
    # Determine the location of the required luchs CMake support framework.
    if (DEFINED ENV{LUCHS_FRAMEWORK_LOCAL_PATH})
        cmake_path( CONVERT "$ENV{LUCHS_FRAMEWORK_LOCAL_PATH}" TO_CMAKE_PATH_LIST LOCAL_PATH )
        cmake_path( ABSOLUTE_PATH LOCAL_PATH NORMALIZE )
        set( LOCAL_PATH "URL" "${LOCAL_PATH}" )
    elseif (DEFINED ENV{LUCHS_FRAMEWORK_GIT_REPOSITORY})
        set( GIT_REPOSITORY "GIT_REPOSITORY" "$ENV{LUCHS_FRAMEWORK_GIT_REPOSITORY}" )
    elseif (EXISTS ${CMAKE_SOURCE_DIR}/.luchs)
        set( LOCAL_PATH "URL" "${CMAKE_SOURCE_DIR}/.luchs" )
    else()
        set( GIT_REPOSITORY "GIT_REPOSITORY" "https://github.com/Bagira80/luchs.git" )
    endif()
    if (DEFINED ENV{LUCHS_FRAMEWORK_GIT_TAG})
        set( GIT_TAG "GIT_TAG" "$ENV{LUCHS_FRAMEWORK_GIT_TAG}" )
    else()
        set( GIT_TAG "GIT_TAG" "main" )
    endif()
    # Load the luchs CMake support framework (and copy it into the build-directory).
    FetchContent_Declare( luchs
        ${LOCAL_PATH}
        ${GIT_REPOSITORY}
        ${GIT_TAG}  # Will be ignored for the URL case!
        SOURCE_DIR ${CMAKE_BINARY_DIR}/_luchs
    )
    unset( LOCAL_PATH )
    unset( GIT_REPOSITORY )
    unset( GIT_TAG )
    FetchContent_GetProperties( luchs )
    if (NOT luchs_POPULATED )
        message( CHECK_START "Initial checkout of luchs common scripts" )
        FetchContent_Populate( luchs )
        message( CHECK_PASS "done" )
        # Load the preparations for top-level CMakeLists.txt file.
        include( "${CMAKE_BINARY_DIR}/_luchs/framework/top-level-preparations.cmake" )
    endif()
endif()
