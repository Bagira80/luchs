##
# @file
# @details Defines a functions which generates a helper script that needs to be used by CPack
#          in order to successfully calculate package dependencies when generating Debian
#          packages.
#

include_guard()

##
# @name generate_cpack_deb_helper_file( output [dependency-targets...] )
# @brief Creates the CPack Debian helper file(s) from the given set of dependency-targets.
# @details Generates the CPack Debian helper file(s) with the given output name that contains the
#          logic for being able to calculate Debian package dependencies from the given
#          dependency-targets.
# @param output The path to the output file(s) which will be generated from the input.
# @param dependency-targets... The names of CMake targets which are the dependencies for which
#        the generated file(s) will be able to calculate the required Debian packages.
# @note Generator-expressions in the output filename will be expanded.
# @note This function does not create the output file until the generation phase. The output file
#       will not yet have been written when this function returns, it is written only after
#       processing all of a project’s CMakeLists.txt files!
#
function( generate_cpack_deb_helper_file output )  # dependency-targets...
    # Small helper for extra indentation:
    set( indentation "      " )

    # Build up the list of generator-expressions for the private directories which might be needed for `dpkg-shlibdeps`.
    set( CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS )
    foreach( dependency IN ITEMS ${ARGN} )
        # The (complicated) generator-expression.
        # Expr: If dependency is neither an IMPORTED nor an INTERFACE target,
        #       than evaluate to the directory of the target's build file.
        string( JOIN "" generator_expr
                "# For dependency:  ${dependency}\n${indentation}"
                "$<"
                    "$<AND:"
                        # (dependency != IMPORTED target)  &&
                        "$<NOT:$<BOOL:$<TARGET_PROPERTY:${dependency},IMPORTED>>>,"
                        # (dependency != INTERFACE target)
                        "$<NOT:$<STREQUAL:$<TARGET_PROPERTY:${dependency},TYPE>,INTERFACE_LIBRARY>>"
                    ">"
                    ":"
                    "$<TARGET_FILE_DIR:${dependency}>"
                ">"
        )
        # Add that generator_expr to the list.
        list( APPEND CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS ${generator_expr} )
    endforeach()

    # Generate the output file with that list.
    list( JOIN CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS "\n${indentation}" CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS )
    file(GENERATE OUTPUT ${output} CONTENT
"# Auto-generated file.

# The variable which will be used by `dpkg-shlibdeps` to parse private dependencies.
list( APPEND CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS
${indentation}${CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS}
)"
    )
endfunction()
