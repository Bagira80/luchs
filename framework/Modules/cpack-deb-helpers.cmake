##
# @file
# @details Defines functions which help preparing CPack in order to generated Debian packages.
#

include_guard()

include( "internal/cpack-deb-helpers" )


##
# @name associate_project_targets_with_deb_packages( cpack_debian_config )
# @brief Stores the associated DEB-package(s) as property in the current project's targets.
# @details The name and version of the associated DEB-package(s) created from the "Runtime" and
#          from the "Development" component of the current project will be stored as property in
#          all targets that will be installed by the current project.  
#          The associated DEB-packages' names will be stored in configuration-specific properties
#          named `ASSOCIATED_DEBIAN_(RUNTIME|DEVELOPMENT)_PACKAGE_<config>`.
# @param cpack_debian_config The cpack project config which contains the DEB-generator specific
#        CPack variables. (It must already exist because it is read in order to extract some
#        CPack variable information.)
#
function( associate_project_targets_with_deb_packages cpack_debian_config )
    # The names of the components of the current project (which possibly have CMake targets associated with them).
    set( runtime_component "${project_component_prefix_fullname}-Runtime" )
    set( development_component "${project_component_prefix_fullname}-Development" )
    set( plugins_component "${project_component_prefix_fullname}-Plugins" )

    # Determine the package-dependency strings (as they will be written in the `depends` field of a
    # DEB-package) for the "Runtime" and "Development" components of the current project.
    # Note: Such a package-dependency string requires the name and (full) version of a DEB-package.
    foreach( config IN ITEMS ${CMAKE_BUILD_TYPE} ${CMAKE_CONFIGURATION_TYPES} )
        block( PROPAGATE current_runtime_package_${config}
                         current_development_package_${config} )
            # Make required prerequisites for including the given script with the CPack settings for
            # the DEB-generator and include that script. This will make the (main) CPack variables from
            # that script available, especially the two we need here (CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME
            # and CPACK_DEBIAN_PACKAGE_COMBINED_VERSION).
            set( CPACK_GENERATOR      "DEB" )
            set( CPACK_BUILD_CONFIG   "${config}" )
            include( ${cpack_debian_config} )
            # Set package-dependency string for the "Runtime" and "Development" components.
            foreach( component IN ITEMS runtime development )
                string( TOUPPER "${${component}_component}" COMPONENT )
                if (DEFINED CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME)
                    set( current_${component}_package_${config} "${CPACK_DEBIAN_${COMPONENT}_PACKAGE_NAME} (= ${CPACK_DEBIAN_PACKAGE_COMBINED_VERSION})" )
                else()
                    unset( current_${component}_package_${config} )
                endif()
            endforeach()
        endblock()
    endforeach()

    # Retrieve the list of all targets which are installed by the current project.
    get_property( runtime_targets     GLOBAL PROPERTY TARGETS_ASSOCIATED_WITH_COMPONENT_${runtime_component} )
    get_property( development_targets GLOBAL PROPERTY TARGETS_ASSOCIATED_WITH_COMPONENT_${development_component} )
    get_property( plugins_targets     GLOBAL PROPERTY TARGETS_ASSOCIATED_WITH_COMPONENT_${plugins_component} )
    # Alias-targets are special (and will not be exported themselves)
    # so the properties should be set on the real, aliased targets instead.
    set( aliased_targets )
    set( alias_targets )
    foreach( target IN LISTS runtime_targets development_targets plugins_targets )
        get_target_property( aliased_target ${target} ALIASED_TARGET )
        if (aliased_target)
            list( APPEND aliased_targets ${aliased_target} )
            list( APPEND alias_targets ${target} )
        endif()
    endforeach()
    list( REMOVE_ITEM runtime_targets     ${alias_targets} )
    list( REMOVE_ITEM development_targets ${alias_targets} )
    list( REMOVE_ITEM plugins_targets     ${alias_targets} )

    # Store the associate package-dependency strings as properties in the targets of the current project.
    foreach( config IN ITEMS ${CMAKE_BUILD_TYPE} ${CMAKE_CONFIGURATION_TYPES} )
        string( TOUPPER "${config}" CONFIG )
        foreach( component IN ITEMS runtime development )
            string( TOUPPER "${component}" COMPONENT )
            if (DEFINED current_${component}_package_${config})
                set_target_properties( ${runtime_targets} ${development_targets} ${plugins_targets} ${aliased_targets}
                    PROPERTIES
                        ASSOCIATED_DEBIAN_${COMPONENT}_PACKAGE_${CONFIG} "${current_${component}_package_${config}}"
                )
                # Make sure that this property will be exported as well!
                set_property( TARGET ${runtime_targets} ${development_targets} ${plugins_targets} ${aliased_targets}
                    APPEND PROPERTY EXPORT_PROPERTIES
                        ASSOCIATED_DEBIAN_${COMPONENT}_PACKAGE_${CONFIG}
                )
            endif()
        endforeach()
    endforeach()
endfunction()


##
# @name generate_cpack_deb_extra_settings_file( outfile )
# @brief Generates the additional CPack file which contains extra settings for the DEB-generator.
# @details The generated file will be stored with the given output name (and path) and it contains
#          the extra settings needed for the DEB-generator in order to create proper Debian
#          packages.
# @param output The path to the output file which will be generated.
# @note The variable `${PROJECT_DEPENDENCIES}` should be set properly to the list of CMake targets
#       on which the current project or more specifically its targets directly depend.
# @note Generator-expressions in the output filename will be expanded.
# @note This function does not create the output file until the generation phase. The output file
#       will not yet have been written when this function returns, it is written only after
#       processing all CMakeLists.txt files!
#
function( generate_cpack_deb_extra_settings_file outfile )
    # Write header comment for generated file.
    string( JOIN "\n" file_content
        "# Auto-generated file, do not modify!"
        "#"
        "# This file is a helper file for CPack's DEB-generator which contains additional CPack variables."
        "#"
        ""
    )

    # Write commands for setting `CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS` variable.
    # Note: The variable `PROJECT_DEPENDENCIES` should have been set already to the list
    #       of dependencies targets of the current project.
    luchs_internal__prepare_cpack_deb_shlibdeps_variable( content ${PROJECT_DEPENDENCIES} )
    list( APPEND file_content ${content} )

    # Generate the output file which will automatically evaluate the generator-expressions.
    list( JOIN file_content "\n\n" file_content )
    file( GENERATE OUTPUT ${outfile} CONTENT "${file_content}" )
endfunction()
