##
# @file
# @details Defines internal helper functions which return strings that can be used to generate a
#          helper script that needs to be used by CPack in order to successfully generate "DEB"
#          packages.
#

include_guard()


##
# @name luchs_internal__prepare_cpack_deb_shlibdeps_variable( output [dependency-targets...] )
# @brief Returns the string for generating extra CPack settings needed for `dpkg-shlibdeps`.
# @details The calculated string will be returned via the given `output` variable and it contains
#          commands for populating variable `CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS` with
#          information extracted from the given set of `dependency-targets`.
# @param output The name of the variable in caller's scope via which the result shall be returned.
# @param dependency-targets... The names of CMake targets which are the dependencies of the current
#        project and from which some information will be extracted (with the help of
#        generator-expressions) and returned.
# @note The returned string contains generator-expressions and therefore must be evaluated during
#       generation-phase!
#
function( luchs_internal__prepare_cpack_deb_shlibdeps_variable output )  # dependency-targets...
    # Build up the list of generator-expressions for the private directories which might be needed for `dpkg-shlibdeps`.
    set( content )  # The content that will be written out, later.
    foreach( dependency IN ITEMS ${ARGN} )
        # Calculate generator-expression for retrieving directory of the binary file of each dependency target.
        set( eval_dependency  "$<GENEX_EVAL:${dependency}>" )
        set( is_target        "$<NOT:$<STREQUAL:x$<TARGET_NAME_IF_EXISTS:${eval_dependency}>x,xx>>" )
        set( is_imported      "$<BOOL:$<TARGET_PROPERTY:${eval_dependency},IMPORTED>>" )
        set( is_interface_lib "$<STREQUAL:$<TARGET_PROPERTY:${eval_dependency},TYPE>,INTERFACE_LIBRARY>" )
        string( JOIN "" generator_expr
            "$<${is_target}:"
                "$<$<AND:$<NOT:${is_imported}>,$<NOT:${is_interface_lib}>>:"
                    "\"$<TARGET_FILE_DIR:${eval_dependency}>\""
                ">"
            ">"
        )
        # Append generator-expression together with its explaining comment to the content.
        list( APPEND content "# From dependency: ${eval_dependency}" "${generator_expr}" )
    endforeach()
    # Construct CMake commands for setting `CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS` to the
    # evaluated generator-expressions.
    set( indentation "      " )  # Identation for prettier output.
    list( JOIN content "\n${indentation}" content )
    if (NOT "${content}" STREQUAL "")
        set( content "${indentation}${content}\n" )
    endif()
    set( content
        "# The variable which will be used by `dpkg-shlibdeps` to parse private dependencies."
        "list( APPEND CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS"
        "${content})"
        "# Remove duplicate and empty entries again."
        "list( REMOVE_DUPLICATES CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS )"
        "list( REMOVE_ITEM CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS \"\" )"
    )
    list( JOIN content "\n" content )

    # Return constructed content.
    set( ${output} "${content}" PARENT_SCOPE )
endfunction()


##
# @name luchs_internal__prepare_cpack_deb_depends_variables( output )
# @brief Returns the string for generating extra CPack settings needed for determining dependencies.
# @details The calculated string will be returned via the given `output` variable and it contains
#          commands for populating variables `CPACK_DEBIAN_<component>_PACKAGE_DEPENDS` with
#          `<component>` denoting one of the `Runtime`, `Development` and `Plugins` components of
#          the current project.
# @param output The name of the variable in caller's scope via which the result shall be returned.
# @note The returned string contains generator-expressions and therefore must be evaluated during
#       generation-phase!
#
function( luchs_internal__prepare_cpack_deb_depends_variables output )
    # The names of the components of the current project (which possibly have CMake targets associated with them).
    set( runtime_component     "${project_component_prefix_fullname}-Runtime" )
    set( development_component "${project_component_prefix_fullname}-Development" )
    set( plugins_component     "${project_component_prefix_fullname}-Plugins" )

    # Retrieve all dependencies which are required during runtime.
    # Note: Only shared libraries are interesting here, because these need to be found during runtime!
    luchs_internal__get_dependencies_from_component( runtime_buildDeps     ONLY_RUNTIME_DEPS COMPONENT ${runtime_component} )
    luchs_internal__get_dependencies_from_component( development_buildDeps ONLY_RUNTIME_DEPS COMPONENT ${development_component} )
    luchs_internal__get_dependencies_from_component( plugins_buildDeps     ONLY_RUNTIME_DEPS COMPONENT ${plugins_component} )
    # Retrieve all dependencies which are required during buildtime of dependent targets.
    luchs_internal__get_dependencies_from_component( runtime_usageDeps     COMPONENT ${runtime_component} )
    luchs_internal__get_dependencies_from_component( development_usageDeps COMPONENT ${development_component} )
    luchs_internal__get_dependencies_from_component( plugins_usageDeps     COMPONENT ${plugins_component} )

    # Construct CMake commands for setting `CPACK_DEBIAN_<runtime_component>_PACKAGE_DEPENDS`.
    luchs_internal__get_property_from_dependencies( content
        ONLY_DYNAMIC
        PROPERTY     "ASSOCIATED_DEBIAN_RUNTIME_PACKAGE_$<UPPER_CASE:$<CONFIG>>"
        DEPENDENCIES ${runtime_buildDeps} ${runtime_usageDeps}
    )
    luchs_internal__prepare_cpack_deb_depends_variable( runtime_var_content COMPONENT ${runtime_component} CONTENT_LIST content )

    # Construct CMake commands for setting `CPACK_DEBIAN_<development_component>_PACKAGE_DEPENDS`.
    # Note: The usage-dependencies of the "Runtime" component are also needed when developing!
    luchs_internal__get_property_from_dependencies( content
        PROPERTY     "ASSOCIATED_DEBIAN_DEVELOPMENT_PACKAGE_$<UPPER_CASE:$<CONFIG>>"
        DEPENDENCIES ${runtime_usageDeps} ${development_buildDeps} ${development_usageDeps}
    )
    luchs_internal__prepare_cpack_deb_depends_variable( development_var_content COMPONENT ${development_component} CONTENT_LIST content )

    # Construct CMake commands for setting `CPACK_DEBIAN_<plugins_component>_PACKAGE_DEPENDS`.
    luchs_internal__get_property_from_dependencies( content
        PROPERTY     "ASSOCIATED_DEBIAN_RUNTIME_PACKAGE_$<UPPER_CASE:$<CONFIG>>"
        DEPENDENCIES ${plugins_buildDeps}
    )
    luchs_internal__get_property_from_dependencies( content2
        PROPERTY     "ASSOCIATED_DEBIAN_DEVELOPMENT_PACKAGE_$<UPPER_CASE:$<CONFIG>>"
        DEPENDENCIES ${plugins_usageDeps}
    )
    list( APPEND content ${content2} )
    luchs_internal__prepare_cpack_deb_depends_variable( plugins_var_content COMPONENT ${plugins_component} CONTENT_LIST content )

    # Combine the CMake commands.
    set( content "${runtime_var_content}\n\n${development_var_content}\n\n${plugins_var_component}" )

    # Return constructed content.
    set( ${output} "${content}" PARENT_SCOPE )
endfunction()


##
# @name luchs_internal__prepare_cpack_deb_depends_variable( output CONTENT_LIST list COMPONENT component )
# @brief Returns the string for determining package-dependencies for the given component.
# @details The calculated string will be returned via the given `output` variable and it contains
#          commands for populating variable `CPACK_DEBIAN_<component>_PACKAGE_DEPENDS` for the
#          given `component`. The given list contains the values/content for that variable.
# @param output The name of the variable in caller's scope via which the result shall be returned.
# @param CONTENT_LIST list The name of the list containing the content for the CPack variable.
# @param COMPONENT component The name of the current project's component for which the CPack
#        variable shall be populated with the content of the given list.
# @note May only ever be called from `luchs_internal__prepare_cpack_deb_depends_variables`.
#
function( luchs_internal__prepare_cpack_deb_depends_variable output )
    cmake_parse_arguments(
         "_luchs"
         ""
         "CONTENT_LIST;COMPONENT"
         ""
         ${ARGN}
    )
    # Some sanity checks.
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments of '${keyword}'!" )
        endforeach()
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        list( JOIN _luchs_UNPARSED_ARGUMENTS "', '" "${_luchs_UNPARSED_ARGUMENTS}")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Additional, unexpected arguments: '${_luchs_UNPARSED_ARGUMENTS}'" )
    endif()
    if (NOT DEFINED _luchs_CONTENT_LIST)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing 'CONTENT_LIST' argument!" )
    endif()
    if (NOT DEFINED _luchs_COMPONENT)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing 'COMPONENT' argument!" )
    else()
        string( TOUPPER "${_luchs_COMPONENT}" COMP )
    endif()

    # Combine the CMake commands.
    set( indentation "      " )  # Identation for prettier output.
    list( JOIN "${_luchs_CONTENT_LIST}" "\n${indentation}" content )
    if (NOT "${content}" STREQUAL "")
        set( content "${indentation}${content}\n" )
    endif()
    set( content
        "# DEB-package dependencies for component ${_luchs_COMPONENT}:"
        "list( APPEND CPACK_DEBIAN_${COMP}_PACKAGE_DEPENDS"
        "${content})"
        "# Remove duplicate and empty entries again."
        "list( REMOVE_DUPLICATES CPACK_DEBIAN_${COMP}_PACKAGE_DEPENDS )"
        "list( REMOVE_ITEM CPACK_DEBIAN_${COMP}_PACKAGE_DEPENDS \"\" )"
    )
    list( JOIN content "\n" content )

    # Return constructed content.
    set( ${output} "${content}" PARENT_SCOPE )
endfunction()


##
# @name luchs_internal__get_dependencies_from_component( dependencies [ONLY_RUNTIME_DEPS] COMPONENT component )
# @brief Returns the list of dependencies of the targets of the given component.
# @details The gathered dependencies will be returned via the given `dependencies` variable and it.
# @param dependencies The name of the variable in caller's scope via which the result shall be
#        returned.
# @param ONLY_RUNTIME_DEPS A boolean flag which determines if only runtime-dependencies shall be
#        considered.
# @param COMPONENT component The name of the component for whose targets the package-dependencies
#        shall be returned.
# @note May only ever be called from `luchs_internal__prepare_cpack_deb_depends_variables`.
# @note Currently, the gathered dependencies of static targets might be incomplete, due to the more
#       complicated propagation of indirect dependencies. This might get fixed in the future.
#
function( luchs_internal__get_dependencies_from_component dependencies )
    cmake_parse_arguments(
         "_luchs"
         "ONLY_RUNTIME_DEPS"
         "COMPONENT"
         ""
         ${ARGN}
    )
    # Some sanity checks.
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments of '${keyword}'!" )
        endforeach()
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        list( JOIN _luchs_UNPARSED_ARGUMENTS "', '" "${_luchs_UNPARSED_ARGUMENTS}")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Additional, unexpected arguments: '${_luchs_UNPARSED_ARGUMENTS}'" )
    endif()
    if (NOT DEFINED _luchs_COMPONENT)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing 'COMPONENT' argument!" )
    endif()

    # Retrieve the list of all targets which are installed by the given component.
    get_property( targets GLOBAL PROPERTY TARGETS_ASSOCIATED_WITH_COMPONENT_${_luchs_COMPONENT} )

    # Retrieve requested dependencies.
    set( deps )
    foreach( target IN LISTS targets )
        if (_luchs_ONLY_RUNTIME_DEPS)
            get_target_property( link_libs ${target} LINK_LIBRARIES )
        else()
            get_target_property( link_libs ${target} INTERFACE_LINK_LIBRARIES )
            # Determine what kind of target the current one is.
            # Note: Static and object library targets also need to propagate their private
            #       (build-)dependencies as usage-requirements (at least partially)!
            get_target_property( type ${target} TYPE )
            if ("${type}" STREQUAL "STATIC_LIBRARY")
                message( AUTHOR_WARNING "${CMAKE_CURRENT_FUNCTION}: To-be-packaged target '${target}' from component '${_luchs_COMPONENT}' is "
                         "a static library, but its private dependencies will not be considered when determining DEB-package dependency!" )
            elseif ("${type}" STREQUAL "OBJECT_LIBRARY")
                message( AUTHOR_WARNING "${CMAKE_CURRENT_FUNCTION}: To-be-packaged target '${target}' from component '${_luchs_COMPONENT}' is "
                         "an object library, but its private dependencies will not be considered when determining DEB-package dependency!" )
            endif()
        endif()
        foreach( link_target IN LISTS link_libs )
            # Unwrap outer layer of `LINK_ONLY` generator-expression.
            if ( link_target MATCHES "^[$][<]LINK_ONLY:(.+)[>]$" )
                set( link_target "${CMAKE_MATCH_1}" )
            endif()

            if (NOT link_target OR link_target MATCHES "^[$][<]BUILD_INTERFACE:(.+)[>]$" )
                continue()
            elseif ( link_target MATCHES "^[$][<]INSTALL_INTERFACE:(.+)[>]$" )
                list( APPEND deps ${CMAKE_MATCH_1} )
            else()
                list( APPEND deps ${link_target} )
            endif()
        endforeach()
    endforeach()
    list( REMOVE_DUPLICATES deps )

    # Return extracted dependencies.
    set( ${dependencies} "${deps}" PARENT_SCOPE )
endfunction()


##
# @name luchs_internal__get_property_from_dependencies( output [ONLY_DYNAMIC] PROPERTY property DEPENDENCIES [targets...] )
# @brief Returns the list of strings which extract the given property from the given dependencies.
# @details The calculated list of strings will be returned via the given `output` variable and they
#          contain the generator-expressions for extracting the given property from the given
#          dependencies targets. Each generator-expression is prepended with a string containing
#          the comment that describes from what dependency that property was taken.
# @param output The name of the variable in caller's scope via which the result shall be returned.
# @param ONLY_DYNAMIC Boolean flag that determines if only shared or module dependency targets
#        shall be considered when trying to access the target dependency.
# @param PROPERTY property The name of the target-property which shall be accessed for each
#        dependency.
# @param DEPENDENCIES targets... The names of CMake targets which are the dependencies from which
#        the given property will be extracted (with the help of generator-expressions).
# @note May only ever be called from `luchs_internal__prepare_cpack_deb_depends_variables`.
#
function( luchs_internal__get_property_from_dependencies output )
    cmake_parse_arguments(
         "_luchs"
         "ONLY_DYNAMIC"
         "PROPERTY"
         "DEPENDENCIES"
         ${ARGN}
    )
    # Some sanity checks.
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            if (keyword STREQUAL "DEPENDENCIES")
                continue()  # No error, because might evaluate to nothing!
            endif()
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments of '${keyword}'!" )
        endforeach()
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        list( JOIN _luchs_UNPARSED_ARGUMENTS "', '" "${_luchs_UNPARSED_ARGUMENTS}")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Additional, unexpected arguments: '${_luchs_UNPARSED_ARGUMENTS}'" )
    endif()
    if (NOT DEFINED _luchs_DEPENDENCIES AND NOT "DEPENDENCIES" IN_LIST _luchs_KEYWORDS_MISSING_VALUES)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing 'DEPENDENCIES' argument!" )
    else()
        list( REMOVE_DUPLICATES _luchs_DEPENDENCIES )
    endif()
    if (NOT DEFINED _luchs_PROPERTY)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing 'PROPERTY' argument!" )
        return()  # Further processing would result in unnecessary additional errors.
    endif()

    # Generate list of generator-expressions which extract the given property from the given dependencies.
    set( content )  # The content that will be returned.
    foreach( dependency IN ITEMS ${_luchs_DEPENDENCIES} )
        # Calculate generator-expression for reading given property of each dependency target.
        set( eval_dependency   "$<GENEX_EVAL:${dependency}>" )
        set( target_type       "$<TARGET_PROPERTY:${eval_dependency},TYPE>" )
        set( aliased_target    "$<TARGET_PROPERTY:${eval_dependency},ALIASED_TARGET>" )
        set( is_target         "$<NOT:$<STREQUAL:x$<TARGET_NAME_IF_EXISTS:${eval_dependency}>x,xx>>" )
        set( is_alias_target   "$<BOOL:${aliased_target}>" )
        if (_luchs_ONLY_DYNAMIC)
            set( is_shared_lib "$<STREQUAL:${target_type},SHARED_LIBRARY>" )
            set( is_module_lib "$<STREQUAL:${target_type},MODULE_LIBRARY>" )
            set( is_acceptable "$<OR:${is_shared_lib},${is_module_lib}>" )
        else()
            set( is_acceptable "1" )  # Always acceptable!
        endif()
        string( JOIN "" generator_expr
            "$<${is_target}:"
                "$<${is_acceptable}:"
                    "$<${is_alias_target}:"
                        "\"$<TARGET_PROPERTY:${aliased_target},${_luchs_PROPERTY}>\""
                    ">"
                    "$<$<NOT:${is_alias_target}>:"
                        "\"$<TARGET_PROPERTY:${eval_dependency},${_luchs_PROPERTY}>\""
                    ">"
                ">"
            ">"
        )
        # Append generator-expression together with its explaining comment to the content.
        list( APPEND content "# From dependency: ${eval_dependency}" "${generator_expr}" )
    endforeach()

    # Return constructed content.
    set( ${output} "${content}" PARENT_SCOPE )
endfunction()
