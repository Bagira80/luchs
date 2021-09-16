##
# @file
# @details Defines a function which generates additional project-specific variables from the given
#          project namespace!
# @note In general, one would give this function the string `${PROJECT_NAME}` as argument!
#


##
# @name make_extra_project_variables( project_hierarchy_name [SEPARATOR <separator>])
# @brief Generates additional project-specific variables from the given project namespace.
# @details The given string will be used by this function to generate the following other project-
#          specific variables that will be set in the caller's scope:
#          * `project_c_identifier` which shall/will be used as identifier (or part of another
#            identifier) in C/C++ code.
#          * `project_output_fullname` which shall/will be used as name for generated libraries or
#            executables etc.
#          * `project_folder_fullname` which shall/will be used in paths.
#          * `project_package_fullname`, `project_package_name` and `project_package_namespace`
#            that shall/will be used when it comes to creating packages (with CPack).
#          * `project_package_separator` which determines what character sequence is used to
#            separate individual parts of the `project_package_*` variables.
#          * `project_component_prefix_fullname`, `project_component_prefix_name` and
#            `project_component_prefix_namespace` that shall/will be used as name-prefix for
#            install-components and creating CMake import-packages. Note, however, that problematic
#            characters (as e.g. colons) will/must be replaced by underscores when these variables
#            are used for file- or directory-names.
#          * `project_component_separator` which determines what character sequence is used to
#            separate individual parts of the `project_component_prefix_*` variables.
#          * `project_export_fullname`, `project_export_name`, `project_export_namespace` and
#            `project_export_parent_name` that are used for exporting CMake targets into CMake
#            import-packages.
# @param project_hierarchy_name The string from which all the other variables will be derived. It
#        should consist of a hierarchy of projects, with the last component representing the
#        current project. (Those components must be separated by the argument to `SEPARATOR`.) In
#        general, `${PROJECT_NAME}` should be given as value. However, that requires it to be in
#        the form of some hierarchy.
# @param SEPARATOR Denotes the separator by which individual components (aka projects) are
#        separated within the given project's hierarchy name. If not given, it defaults to `.`.
# @note The string given to this function should contain multiple components. Therefore, it would
#       also be possible to give this function the full name of a properly named alias target (with
#       namespace syntax) as long as `::` is given as `SEPARATOR` as well.
# @note This function is supposed to be called from the `common-project-post-actions.cmake` script
#       for each project with `${PROJECT_NAME}` as argument.
#
function( make_extra_project_variables project_hierarchy_name )
    cmake_parse_arguments(
         "_luchs"
         ""
         "SEPARATOR"
         ""
         ${ARGN}
    )
    # Some sanity checks.
    if ("${project_hierarchy_name}" STREQUAL "")
        message( FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Argument 'project_hierarchy_name' evaluates to the empty string!" )
    endif()
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing argument for '${keyword}'!" )
        endforeach()
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Additional, unexpected arguments!" )
    endif()
    if (NOT DEFINED _luchs_SEPARATOR)
        set( _luchs_SEPARATOR "." )
    endif()
    string( REPLACE "${_luchs_SEPARATOR}" "_" tmp_project_name "${project_hierarchy_name}" )
    if ("${tmp_project_name}" MATCHES "^.*[:]+.*$")
        message( FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Argument 'project_hierarchy_name' contains illegal characters! (It contains colons "
                             "that are not used as project-separators. Did you forget to properly set argument 'PROJECT_SEPARATOR'?)" )
    endif()


    # Calculate helper variables.
    # - Index of last separator:
    string( FIND "${project_hierarchy_name}" "${_luchs_SEPARATOR}" index REVERSE )
    # - Fullname:
    set( fullname "${project_hierarchy_name}" )
    # - Basename:
    if (index EQUAL -1)
        set( basename "${fullname}" )
    else()
        string( LENGTH "${_luchs_SEPARATOR}" length )
        math( EXPR basename_index "${index} + ${length}" )
        string( SUBSTRING "${fullname}" ${basename_index} -1 basename )
    endif()
    # - Parent-namespace (aka path):
    if (index EQUAL -1)
        set( parent_namespace "" )
    else()
        string( SUBSTRING "${fullname}" 0 ${index} parent_namespace )
    endif()


    #
    # The format of the following variables may NEVER be changed!
    #


    # Calculate project_c_identifier.
    # - all uppercase
    # - components separated by single '_'
    # - non-alphanumeric characters replaced by '_'
    string( TOUPPER "${fullname}" project_c_identifier )
    string( REPLACE "${_luchs_SEPARATOR}" "_" project_c_identifier "${project_c_identifier}" )
    string( MAKE_C_IDENTIFIER "${project_c_identifier}" project_c_identifier )
    set( project_c_identifier "${project_c_identifier}" PARENT_SCOPE )

    # Calculate project_folder_fullname.
    # - all lowercase
    # - namespaces separated by single '/'
    string( TOLOWER "${fullname}" project_folder_fullname )
    string( REPLACE "${_luchs_SEPARATOR}" "/" project_folder_fullname "${project_folder_fullname}" )
    set( project_folder_fullname "${project_folder_fullname}" PARENT_SCOPE )


    # Calculate project_export_name.
    # - all lowercase
    string( TOLOWER "${basename}" project_export_name )
    set( project_export_name "${project_export_name}" PARENT_SCOPE )

    # Calculate project_export_namespace.
    # - original (mixed) case
    # - namespaces separated by '::'
    string( REPLACE "${_luchs_SEPARATOR}" "::" project_export_namespace "${parent_namespace}" )
    set( project_export_namespace "${project_export_namespace}" PARENT_SCOPE )

    # Calculate project_export_fullname.
    # - original (mixed) case except for basename which is lower case
    # - namespaces separated by '::'
    if ("${project_export_namespace}" STREQUAL "")
        set( project_export_fullname "${project_export_name}" PARENT_SCOPE )
    else()
        set( project_export_fullname "${project_export_namespace}::${project_export_name}" PARENT_SCOPE )
    endif()

    # Calculate project_export_parent_name.
    # - original (mixed) case
    string( FIND "${project_export_namespace}" ":" project_export_parent_name REVERSE )
    math( EXPR project_export_parent_name "${project_export_parent_name} + 1" )
    string( SUBSTRING "${project_export_namespace}" ${project_export_parent_name} -1 project_export_parent_name )
    set( project_export_parent_name "${project_export_parent_name}" PARENT_SCOPE )


    #
    # The format of the following variables should, in general, not be changed! At least they may
    # not contain colons (or other characters) that might be problematic at the file-system level.
    #


    # Calculate project_output_fullname.
    # - all lowercase
    # - components separated by single '_'
    string( TOLOWER "${fullname}" project_output_fullname )
    string( REPLACE "${_luchs_SEPARATOR}" "_" project_output_fullname "${project_output_fullname}" )
    set( project_output_fullname "${project_output_fullname}" PARENT_SCOPE )


    # The separator for project packages.
    # - namespaces separated by single '-'
    set( project_package_separator "-" )
    set( project_package_separator "${project_package_separator}" PARENT_SCOPE )

    # Calculate project_package_name.
    # - all lowercase
    string( TOLOWER "${basename}" project_package_name )
    set( project_package_name "${project_package_name}" PARENT_SCOPE )

    # Calculate project_package_namespace.
    # - all lowercase
    # - namespaces separated by '${project_package_separator}'
    string( TOLOWER "${parent_namespace}" project_package_namespace )
    string( REPLACE "${_luchs_SEPARATOR}" "${project_package_separator}" project_package_namespace "${project_package_namespace}" )
    set( project_package_namespace "${project_package_namespace}" PARENT_SCOPE )

    # Calculate project_package_fullname.
    # - all lowercase
    # - namespaces separated by '${project_package_separator}'
    string( TOLOWER "${fullname}" project_package_fullname )
    string( REPLACE "${_luchs_SEPARATOR}" "${project_package_separator}" project_package_fullname "${project_package_fullname}" )
    set( project_package_fullname "${project_package_fullname}" PARENT_SCOPE )


    #
    # The format of the following variables chould be changed! However, characters (like colons) that might
    # be problematic at the file-system level must be replaced by underscores when these variables are used
    # in filenames etc. (Note, that luchs enforces this within its own code.)
    #


    # The separator for project components.
    # - namespaces separated by '::'
    set( project_component_separator "::" )
    set( project_component_separator "${project_component_separator}" PARENT_SCOPE )

    # Calculate project_component_prefix_name.
    # - original (mixed) case
    set( project_component_prefix_name "${basename}" )
    set( project_component_prefix_name "${project_component_prefix_name}" PARENT_SCOPE )

    # Calculate project_component_prefix_namespace.
    # - original (mixed) case
    # - namespaces separated by '${project_component_separator}'
    string( REPLACE "${_luchs_SEPARATOR}" "${project_component_separator}" project_component_prefix_namespace "${parent_namespace}" )
    set( project_component_prefix_namespace "${project_component_prefix_namespace}" PARENT_SCOPE )

    # Calculate project_component_fullname.
    # - original (mixed) case
    # - namespaces separated by '${project_component_separator}'
    string( REPLACE "${_luchs_SEPARATOR}" "${project_component_separator}" project_component_prefix_fullname "${fullname}" )
    set( project_component_prefix_fullname "${project_component_prefix_fullname}" PARENT_SCOPE )
endfunction()
