##
# @file
# @brief Defines helper functions for the functions from the `add_project_targets` CMake module.
#


##
# @name luchs_internal__add_project_targets__sanity_checks( caller name )
# @brief Makes some common (sanity) checks.
# @param caller The name of the calling function.
# @param name The name of the target. It must be in the form of `[$][{]PROJECT_NAME[}](-.+)?`.
# @return The variable `target_name_with_namespace` will be returned into the caller scope.
# @note The variables `PROJECT_NAME`, `project_export_fullname`, `PROJECT_SOURCE_DIR`,
#       `PROJECT_BINARY_DIR` (and possibly `PROJECT_VERSION_MAJOR`, `PROJECT_VERSION_MINOR` and
#       `PROJECT_VERSION_PATCH`) need to be defined!
# @note Therefore the `project` command and its pre-action should have been called before.
# @note May only be called from the functions declared in the `add_project_targets` CMake module.
#
function( luchs_internal__add_project_targets__sanity_checks caller name )
    set( CMAKE_CURRENT_FUNCTION "${caller}" )  # Make the current function transparent.
    # Check that required variables are defined.
    if (NOT DEFINED PROJECT_NAME          OR NOT DEFINED project_export_fullname OR
        NOT DEFINED PROJECT_SOURCE_DIR    OR NOT DEFINED PROJECT_BINARY_DIR      OR
       (NOT CMAKE_CURRENT_FUNCTION STREQUAL "add_project_test" AND
       (NOT DEFINED PROJECT_VERSION_MAJOR OR NOT DEFINED PROJECT_VERSION_MINOR OR NOT DEFINED PROJECT_VERSION_PATCH)))
        message( FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Some of the required variables are not defined! (Did you forget to call the 'project' command with its pre-actions?)" )
    endif()

    # Check if unknown arguments where given
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        list( JOIN _luchs_UNPARSED_ARGUMENTS "', '" "${_luchs_UNPARSED_ARGUMENTS}")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Additional, unexpected arguments: '${_luchs_UNPARSED_ARGUMENTS}'" )
    endif()

    # Check `name` for correct format.
    if ("${name}" STREQUAL "${PROJECT_NAME}")
        set( target_name_with_namespace "${project_export_fullname}" )
    elseif ("${name}" MATCHES "${PROJECT_NAME}-(.+)")
        set( target_name_with_namespace "${project_export_fullname}::${CMAKE_MATCH_1}" )
    else()
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Cannot process target ('${name}') because its name does neither equal '\${PROJECT_NAME}' nor start with '\${PROJECT_NAME}-'." )
    endif()
    # Return `target_name_with_namespace`.
    set( target_name_with_namespace "${target_name_with_namespace}" PARENT_SCOPE )
endfunction()


##
# @name luchs_internal__add_project_targets__common_setting( caller target alias_name )
# @brief Adds some common settings to the given target.
# @param caller The name of the calling function.
# @param target The target on which some common settings will be set.
# @param alias_name The alias name of the given target (probably with namespace syntax).
# @note May only be called from the functions declared in the `add_project_targets` CMake module.
#
function( luchs_internal__add_project_targets__common_setting caller target alias_name )
    set( CMAKE_CURRENT_FUNCTION "${caller}" )  # Make the current function transparent.
    # Calculate the PROJECT_LABEL property for proper displaying in IDEs.
    set( unicodeProportionChar "∷" )  # A fixed double-colon (U+2237) that does not collide with the drive-separator on Windows systems.
    string( REPLACE "::" "${unicodeProportionChar}" project_label "${alias_name}" )

    # Set display-name for IDEs, version and shared-object version.
    set_target_properties( ${target} PROPERTIES
        PROJECT_LABEL "${project_label}"
        VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}
        SOVERSION ${PROJECT_VERSION_MAJOR}
    )

    # Add default (public) include search paths.
    target_include_directories( ${target}
        PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
    )

    # Special handling for specific callers.
    if (CMAKE_CURRENT_FUNCTION STREQUAL "add_project_test")
        # Add default (private) include search paths.
        target_include_directories( ${target}
            PRIVATE
                ${CMAKE_CURRENT_SOURCE_DIR}/tests
                ${CMAKE_CURRENT_BINARY_DIR}/tests
                ${PROJECT_SOURCE_DIR}/tests
                ${PROJECT_BINARY_DIR}/tests
        )
        # Make sure to create the test executables in a subdirectory "tests" (unless on Windows).
        if (NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
            set_target_properties( ${name} PROPERTIES
                RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/tests"
            )
        endif()
    else()
        # Add default (private) include search paths.
        target_include_directories( ${target}
            PRIVATE
                ${CMAKE_CURRENT_SOURCE_DIR}/src
                ${CMAKE_CURRENT_BINARY_DIR}/src
                ${PROJECT_SOURCE_DIR}/src
                ${PROJECT_BINARY_DIR}/src
        )
    endif()
endfunction()
