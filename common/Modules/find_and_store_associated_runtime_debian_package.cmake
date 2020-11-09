##
# @file
# @details Defines a function which searches for runtime Debian packages associated with some
#          given targets and stores the names of the found packages in properties of the targets.
#          Those properties are called:
#
#          * ASSOCIATED_RUNTIME_DEBIAN_PACKAGE
#          * ASSOCIATED_RUNTIME_DEBIAN_PACKAGE_<CONFIG>
#

include_guard()

include( ${CMAKE_CURRENT_LIST_DIR}/available_configurations.cmake )

##
# @name find_and_store_associated_runtime_debian_package( <options> TARGETS targets... )
# @brief Sets the ASSOCIATED_RUNTIME_DEBIAN_PACKAGE property of the given target(s) if applicable.
# @details For each of the given targets this function tries to find the associated runtime Debian
#          package (if any) and stores the result in the ASSOCIATED_RUNTIME_DEBIAN_PACKAGE and
#          ASSOCIATED_RUNTIME_DEBIAN_PACKAGE_<CONFIG> properties on these targets.
# @param <options> Options `GROUP_NAME` and `TIMEOUT` that each take a value.
#        `GROUP_NAME`'s value will be printed in a status-message, while the `TIMEOUT` in seconds
#        determines after what time this function times out.
# @param targets... The targets for which the associated runtime Debian package will be searched
#        and whose appropriate properties will be set accordingly.
#
function( find_and_store_associated_runtime_debian_package )
    cmake_parse_arguments(
        "_"
        ""
        "GROUP_NAME;TIMEOUT"
        "TARGETS"
        ${ARGN}
    )

    # Check and verify option: GROUP_NAME
    if ("GROUP_NAME" IN_LIST __KEYWORDS_MISSING_VALUES)
        message( SEND_ERROR "Option GROUP_NAME is missing its value!" )
        return()
    elseif (NOT DEFINED __GROUP_NAME)
        set( __GROUP_NAME "some targets" )
    endif()

    # Check and verify option: TIMEOUT
    if ("TIMEOUT" IN_LIST __KEYWORDS_MISSING_VALUES)
        message( SEND_ERROR "Option TIMEOUT is missing its value!" )
        return()
    elseif (NOT DEFINED __TIMEOUT)
        message( STATUS "SET __TIMEOUT" )
        set( __TIMEOUT 10 )  # Default time-out of 10 seconds.
    elseif (NOT "${__TIMEOUT}" MATCHES "[0-9]+")
        message( SEND_ERROR "Illegal timeout specified. (Must be a (positive) number!)" )
        return()
    endif()

    # Check for unparsed arguments.
    if (DEFINED __UNPARSED_ARGUMENTS)
        message( SEND_ERROR "Received unknown arguments. (${__UNPARSED_ARGUMENTS})" )
        return()
    endif()

    # Check and verify option: TARGETS
    if (NOT DEFINED __TARGETS)
        if ("TARGETS" IN_LIST __KEYWORDS_MISSING_VALUES)
            # Short-circuit if no or empty targets given.
            return()
        else()
            message( SEND_ERROR "Required option TARGETS is missing!" )
            return()
        endif()
    else()
        # Verify that targets are known.
        set( unknown_targets )
        foreach( target IN LISTS __TARGETS )
            if (NOT TARGET ${target})
                list( APPEND unknown_targets ${target} )
            endif()
        endforeach()
        if (DEFINED unknown_targets)
            list( JOIN unknown_targets " " unknown_targets )
            message( SEND_ERROR "Some given targets are unknown. (Unknown targets: ${unknown_targets})" )
            return()
        endif()
    endif()


    # Prepare list of available configurations.
    get_available_configurations( configurations )
    list( APPEND configurations "" )  # Special "empty" configuration
    list( REMOVE_DUPLICATES configurations )

    # Collect arguments for (parallelized) search of associated Debian packages.
    set( target_names )
    set( properties )
    set( search_files )
    foreach( target IN ITEMS ${__TARGETS} )
        foreach( config IN LISTS configurations )
            # Set configuration postfix for all configurations (except for the empty one).
            set( config_postfix )
            if (config)
                string( TOUPPER "_${config}" config_postfix )
            endif()
            # Retrieve the path to the associated library or executable file (if any).
            get_target_property( location ${target} LOCATION${config_postfix} )
            if (location)
                list( APPEND target_names ${target} )
                list( APPEND properties ASSOCIATED_RUNTIME_DEBIAN_PACKAGE${config_postfix} )
                list( APPEND search_files ${location} )
            endif()
        endforeach()
    endforeach()

    # Search Debian packages.
    if (search_files)
        message( CHECK_START "Looking for Debian package(s) of ${__GROUP_NAME}" )
        execute_process( COMMAND "parallel" "--jobs" "0" "--link"
                                 "\"${CMAKE_CURRENT_FUNCTION_LIST_DIR}/Helpers/find_associated_debian_package.sh\""
                                 "{1}" "{2}" "{3}"
                                 ":::" ${search_files}
                                 ":::" ${target_names}
                                 ":::" ${properties}
                         TIMEOUT ${__TIMEOUT}
                         RESULT_VARIABLE return_code
                         OUTPUT_VARIABLE result
                         ERROR_VARIABLE error
                         OUTPUT_STRIP_TRAILING_WHITESPACE
                         ERROR_STRIP_TRAILING_WHITESPACE
        )
        if (NOT return_code EQUAL 0)
            message( CHECK_FAIL "error: ${return_code} ${error}" )
        else()
            message( CHECK_PASS "done" )

            # Set properties on targets.
            string( REPLACE "\n" ";" lines "${result}" )
            foreach( line IN LISTS lines )
                string( REGEX MATCH "^[^ \t]+" package_name "${line}" )
                string( REGEX REPLACE "^${package_name}[ \t]" "" line "${line}" )
                string( REGEX MATCH "^[^ \t]+" package_version "${line}" )
                string( REGEX REPLACE "^${package_version}[ \t]" "" line "${line}" )
                string( REGEX MATCH "^[^ \t]+" target_name "${line}" )
                string( REGEX REPLACE "^${target_name}[ \t]" "" line "${line}" )
                string( REGEX MATCH "^[^ \t]+" prop_name "${line}" )
                if (package_version)
                    set_target_properties( ${target_name} PROPERTIES ${prop_name} "${package_name} (= ${package_version})" )
                elseif (package_name)
                    set_target_properties( ${target_name} PROPERTIES ${prop_name} "${package_name}" )
                endif()
            endforeach()
        endif()
    endif()
endfunction()
