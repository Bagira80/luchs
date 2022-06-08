##
# @file
# @details Defines functions which help preparing CPack in order to generated Debian packages.
#

include_guard()


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
