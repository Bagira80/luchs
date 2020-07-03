##
# @file
# @details Defines a function for loading ORGANIZATION dependencies, either by using `add_subdirectory` or by fetching
#          them using `FetchContent`.
#

include_guard()


##
# @name load_dependency( dependency_name <options>... )
# @brief Tries to load the dependency via `add_subdirectory` and falls back to `FetchContent` if not possible.
# @param dependency_name The name of the ORGANIZATION dependency that shall be loaded.
#
macro( load_dependency dependency_name )

    cmake_parse_arguments(
        "_"
        ""
        "PARENT_PROJECT_NAME;GIT_REPOSITORY"
        ""
        ${ARGN}
    )

    # Load dependency via `add_subdirectory`?
    if (__PARENT_PROJECT_NAME AND
        (DEFINED CACHE{${__PARENT_PROJECT_NAME}_SOURCE_DIR} AND
         DEFINED CACHE{${__PARENT_PROJECT_NAME}_BINARY_DIR} AND
         EXISTS "${${__PARENT_PROJECT_NAME}_SOURCE_DIR}/${dependency_name}"))

        add_subdirectory( "${${__PARENT_PROJECT_NAME}_SOURCE_DIR}/${dependency_name}"
                          "${${__PARENT_PROJECT_NAME}_BINARY_DIR}/${dependency_name}" )

    # Load dependency via `FetchContent`?
    else()

        # Prepare `GIT_REPOSITORY` option.
        if (__GIT_REPOSITORY)
            set( __GIT_REPOSITORY_option "${__GIT_REPOSITORY}" )
            list( PREPEND __GIT_REPOSITORY_option GIT_REPOSITORY )
        endif()

        # Fetch dependency.
        include( FetchContent )
        string( JOIN "." __fetch_dependency_name ${__PARENT_PROJECT_NAME} ${dependency_name} )
        FetchContent_Declare( FETCHED_${__fetch_dependency_name}
            ${__GIT_REPOSITORY_option}
            ${__UNPARSED_ARGUMENTS}
        )
        FetchContent_MakeAvailable( FETCHED_${__fetch_dependency_name} )

        # Cleanup
        unset( __fetch_dependency_name )
        unset( __GIT_REPOSITORY_option )

    endif()

    # Cleanup
    unset( __GIT_REPOSITORY )
    unset( __PARENT_PROJECT_NAME )
    unset( __UNPARSED_ARGUMENTS )

endmacro()
