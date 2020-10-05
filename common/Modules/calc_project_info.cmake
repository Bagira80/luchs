##
# @file
# @details Defines a functions which calculates additional project information from the
#          already defined project information variables and provides this as variables.
#

include_guard()

##
# @name calc_project_info()
# @brief Calculate additional project information and provide it in variables.
# @details The variable `project_namespace` needs to be defined before calling this function. It
#          will be used by this function to calculate the following other variables that will be
#          set in the caller's scope:
#          * project_output_fullname
#          * project_package_fullname
#          * project_package_name
#          * project_package_namespace
#          * project_component_fullname
#          * project_component_name
#          * project_component_namespace
#          * project_export_fullname
#          * project_export_name
#          * project_export_namespace
#          * project_export_parent_name
# @note This function is supposed to be called from the `common-project-post-actions.cmake` script
#       for each project.
#
function( calc_project_info )
    if (NOT project_namespace OR
        "${project_namespace}" STREQUAL "" OR
        NOT "${project_namespace}" MATCHES "^[^: \t]+(::[^: \t]+)+$")
        message( SEND_ERROR "Cannot calculate additional project information. "
                            "[Reason: Input variable \"project_namespace\" is not set (properly).]"
        )
        return()
    endif()


    # Fullname:
    set( fullname "${project_namespace}" )

    # Basename:
    string( FIND "${fullname}" ":" basename REVERSE )
    math( EXPR basename "${basename} + 1" )
    string( SUBSTRING "${fullname}" ${basename} "-1" basename )

    # Parent-namespace (aka path):
    string( FIND "${fullname}" "::" parent_namespace REVERSE )
    if ("${parent_namespace}" EQUAL -1)
        set( parent_namespace "" )
    else()
        string( SUBSTRING "${fullname}" "0" ${parent_namespace} parent_namespace )
    endif()


    # Calculated project_output_fullname.
    # - all lowercase
    # - namespaces separated by single '_'
    string( TOLOWER "${fullname}" project_output_fullname )
    string( REGEX REPLACE "::" "_" project_output_fullname "${project_output_fullname}" )
    set( project_output_fullname "${project_output_fullname}" PARENT_SCOPE )


    # Calculated project_package_name.
    # - all lowercase
    string( TOLOWER "${basename}" project_package_name )
    set( project_package_name "${project_package_name}" PARENT_SCOPE )

    # Calculate project_package_namespace.
    # - all lowercase
    # - namespaces separated by single '-'
    string( TOLOWER "${parent_namespace}" project_package_namespace )
    string( REGEX REPLACE "::" "-" project_package_namespace "${project_package_namespace}" )
    set( project_package_namespace "${project_package_namespace}" PARENT_SCOPE )

    # Calculated project_package_fullname.
    # - all lowercase
    # - namespaces separated by single '-'
    string( TOLOWER "${fullname}" project_package_fullname )
    string( REGEX REPLACE "::" "-" project_package_fullname "${project_package_fullname}" )
    set( project_package_fullname "${project_package_fullname}" PARENT_SCOPE )


    # Calculated project_component_name.
    # - original (mixed) case
    set( project_component_name "${basename}" )
    set( project_component_name "${project_component_name}" PARENT_SCOPE )

    # Calculated project_component_namespace.
    # - original (mixed) case
    # - namespaces separated by single '.'
    string( REGEX REPLACE "::" "." project_component_namespace "${parent_namespace}" )
    set( project_component_namespace "${project_component_namespace}" PARENT_SCOPE )

    # Calculated project_component_fullname.
    # - original (mixed) case
    # - namespaces separated by single '.'
    string( REGEX REPLACE "::" "." project_component_fullname "${fullname}" )
    set( project_component_fullname "${project_component_fullname}" PARENT_SCOPE )


    # Calculated project_export_name.
    # - all lowercase
    string( TOLOWER "${basename}" project_export_name )
    set( project_export_name "${project_export_name}" PARENT_SCOPE )

    # Calculated project_export_namespace.
    # - original (mixed) case
    # - namespaces separated by '::'
    set( project_export_namespace "${parent_namespace}" )
    set( project_export_namespace "${project_export_namespace}" PARENT_SCOPE )

    # Calculated project_export_fullname.
    # - original (mixed) case except for basename which is lower case
    # - namespaces separated by '::'
    if ("${project_export_namespace}" STREQUAL "")
        set( project_export_fullname "${project_export_name}" PARENT_SCOPE )
    else()
        set( project_export_fullname "${project_export_namespace}::${project_export_name}" PARENT_SCOPE )
    endif()

    # Calculated project_export_parent_name.
    # - original (mixed) case
    string( FIND "${project_export_namespace}" ":" project_export_parent_name REVERSE )
    math( EXPR project_export_parent_name "${project_export_parent_name} + 1" )
    string( SUBSTRING "${project_export_namespace}" ${project_export_parent_name} "-1" project_export_parent_name )
    set( project_export_parent_name "${project_export_parent_name}" PARENT_SCOPE )
endfunction()
