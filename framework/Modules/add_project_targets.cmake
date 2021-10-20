##
# @file
# @details Defines functions which create new library/executable/test targets for projects
#          and make some additional settings on these targets.
# @note They are extended versions of the `add_library`, `add_executable` and `add_test` commands.
#

include_guard()

include( "internal/add_project_targets_helper" )


##
# @name add_project_library( name [type] [EXCLUDE_FROM_ALL] )
# @brief Creates a new library target with the given name (and type) and some default settings.
# @details Creates a new library target with the given name and an alias. If the name equals
#          `${PROJECT_NAME}` the alias will be `${project_export_namespace}`. If the name instead
#          equals `${PROJECT_NAME}-<basename>` the alias will be
#          `${project_export_namespace}::<basename>`.  
#          Additionally it sets some include search-paths for that target and sets its
#          `PROJECT_LABEL` property to a sensible value.
# @param name The name of the target. It must be in the form of `[$][{]PROJECT_NAME[}](-.+)?`.
# @param type The type of target. Must be either not given (in which case the `BUILD_SHARED_LIBS`
#        variable determines its type) or one of: `SHARED`, `STATIC`, `MODULE`, `OBJECT` or
#        `INTERFACE`,
# @param EXCLUDE_FROM_ALL Determines if the target should be built by default.
# @note The variables `PROJECT_NAME`, `project_export_namespace`, `PROJECT_VERSION_MAJOR`,
#       `PROJECT_VERSION_MINOR`, `PROJECT_VERSION_PATCH`, `PROJECT_SOURCE_DIR` and
#       `PROJECT_BINARY_DIR` need to be defined!
# @note Therefore the `project` command and its pre-action should have been called before.
#
function( add_project_library name )
    cmake_parse_arguments(
         "_luchs"
         "EXCLUDE_FROM_ALL;SHARED;STATIC;MODULE;OBJECT;INTERFACE"
         ""
         ""
         ${ARGN}
    )
    # Some sanity checks.
    luchs_internal__add_project_targets__sanity_checks( ${CMAKE_CURRENT_FUNCTION} ${name} )

    # Determine if `EXCLUDE_FROM_ALL` was requested.
    if ("${_luchs_EXCLUDE_FROM_ALL}")
        set( _luchs_EXCLUDE_FROM_ALL "EXCLUDE_FROM_ALL" )
    else()
        unset( _luchs_EXCLUDE_FROM_ALL )
    endif()

    # Determine given type (if any).
    set( type )
    if ("${_luchs_SHARED}")
        list( APPEND type "SHARED" )
    endif()
    if ("${_luchs_STATIC}")
        list( APPEND type "STATIC" )
    endif()
    if ("${_luchs_MODULE}")
        list( APPEND type "MODULE" )
    endif()
    if ("${_luchs_OBJECT}")
        list( APPEND type "OBJECT" )
    endif()
    if ("${_luchs_INTERFACE}")
        list( APPEND type "INTERFACE" )
    endif()
    list( LENGTH type length )
    if (length GREATER "1" )
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Got multiple values for optional parameter 'type'. (Only one is allowed.)" )
    endif()

    # Create library target and its alias.
    add_library( ${name} ${type} ${_luchs_EXCLUDE_FROM_ALL} )
    add_library( ${target_name_with_namespace} ALIAS ${name} )

    # Make common settings on that target.
    luchs_internal__add_project_targets__common_setting( ${CMAKE_CURRENT_FUNCTION} ${name} ${target_name_with_namespace} )
endfunction()


##
# @name add_project_executable( name [EXCLUDE_FROM_ALL] )
# @brief Creates a new executable target with the given name and some default settings.
# @details Creates a new executable target with the given name and an alias. If the name equals
#          `${PROJECT_NAME}` the alias will be `${project_export_namespace}`. If the name instead
#          equals `${PROJECT_NAME}-<basename>` the alias will be
#          `${project_export_namespace}::<basename>`.  
#          Additionally it sets some include search-paths for that target and sets its
#          `PROJECT_LABEL` property to a sensible value.
# @param name The name of the target. It must be in the form of `[$][{]PROJECT_NAME[}](-.+)?`.
# @param EXCLUDE_FROM_ALL Determines if the target should be built by default.
# @note The variables `PROJECT_NAME`, `project_export_namespace`, `PROJECT_VERSION_MAJOR`,
#       `PROJECT_VERSION_MINOR`, `PROJECT_VERSION_PATCH`, `PROJECT_SOURCE_DIR` and
#       `PROJECT_BINARY_DIR` need to be defined!
# @note Therefore the `project` command and its pre-action should have been called before.
#
function( add_project_executable name )
    cmake_parse_arguments(
         "_luchs"
         "EXCLUDE_FROM_ALL"
         ""
         ""
         ${ARGN}
    )
    # Some sanity checks.
    luchs_internal__add_project_targets__sanity_checks( ${CMAKE_CURRENT_FUNCTION} ${name} )

    # Determine if `EXCLUDE_FROM_ALL` was requested.
    if ("${_luchs_EXCLUDE_FROM_ALL}")
        set( _luchs_EXCLUDE_FROM_ALL "EXCLUDE_FROM_ALL" )
    else()
        unset( _luchs_EXCLUDE_FROM_ALL )
    endif()

    # Create library target and its alias.
    add_executable( ${name} ${_luchs_EXCLUDE_FROM_ALL} )
    add_executable( ${target_name_with_namespace} ALIAS ${name} )

    # Make common settings on that target.
    luchs_internal__add_project_targets__common_setting( ${CMAKE_CURRENT_FUNCTION} ${name} ${target_name_with_namespace} )
endfunction()


##
# @name add_project_test( name [DISPLAYED_TEST_ID] )
# @brief Creates a new test target with the given name and some default settings.
# @details Creates a new test target with the given name and an alias for that executable target.
#          If the name equals `${PROJECT_NAME}` the alias will be `${project_export_fullname}`. If
#          the name instead equals `${PROJECT_NAME}-<basename>` the alias will be
#          `${project_export_fullname}::<basename>`.  
#          Additionally it sets some include search-paths for that target and sets its
#          `PROJECT_LABEL` property to a sensible value.
# @param name The name of the target. It must be in the form of `[$][{]PROJECT_NAME[}](-.+)?`.
# @param DISPLAYED_TEST_ID The additional identifier which will be displayed when running the
#        test. (It is helpful for grouping.) If not given it defaults to the number `1´.
# @note The variables `PROJECT_NAME`, `project_export_fullname`, `PROJECT_SOURCE_DIR` and
#       `PROJECT_BINARY_DIR` need to be defined!
# @note Therefore the `project` command and its pre-action should have been called before.
#
function( add_project_test name )
    cmake_parse_arguments(
         "_luchs"
         ""
         "DISPLAYED_TEST_ID"
         ""
         ${ARGN}
    )
    # Some sanity checks.
    luchs_internal__add_project_targets__sanity_checks( ${CMAKE_CURRENT_FUNCTION} ${name} )

    # Check if option DISPLAYED_TEST_ID was given without any value.
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Given option 'DISPLAYED_TEST_ID' is missing its value!" )
    endif()

    # Set default value for DISPLAYED_TEST_ID option?
    if (NOT DEFINED _luchs_DISPLAYED_TEST_ID OR "${_luchs_DISPLAYED_TEST_ID}" STREQUAL "")
        set( _luchs_DISPLAYED_TEST_ID "1" )
    endif()

    # Create test target.
    add_executable( ${name} )
    add_executable( ${target_name_with_namespace} ALIAS ${name} )

    # Make common settings on that target.
    luchs_internal__add_project_targets__common_setting( ${CMAKE_CURRENT_FUNCTION} ${name} ${target_name_with_namespace} )

    # Register the test target as new test.
    add_test( NAME "${project_export_fullname}::test_${_luchs_DISPLAYED_TEST_ID}{ ${name} }"
        COMMAND ${name}
        WORKING_DIRECTORY "$<TARGET_FILE_DIR:${name}>"
    )
endfunction()
