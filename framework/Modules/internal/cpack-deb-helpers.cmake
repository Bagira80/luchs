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
