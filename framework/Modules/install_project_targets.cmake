##
# @file
# @details Defines functions which install headers/targets/debug-symbols for projects.
# @note These functions should be used by each CMakeLists.txt that wants to install its targets.
# @note These functions are extended versions of the `install` commands.
#

include_guard()


include( "GNUInstallDirs" )
# Note: It is recommended to set CMAKE_INSTALL_DOCDIR after each include of GNUInstallDirs!
set( CMAKE_INSTALL_DOCDIR "${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME}" )


##
# @name install_project_headers()
# @brief Installs the public headers for the current project.
# @details The public headers will be installed and associated with the "DEVELOPMENT"
#          install-component of the current project. The name of the associated install-component
#          will be `${project_component_prefix_fullname}-Development`.
# @note From CMake 3.23 on this function should no longer be used, because public headers should be
#       installed automatically by calling function `install_project_targets`.
#
function( install_project_headers )
    # 1. Some sanity checks.
    if ("${project_component_prefix_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_prefix_fullname'!" )
    endif()
    if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.23")
        message( WARNING "${CMAKE_CURRENT_FUNCTION}: Consider using CMake's 'FILE_SET' feature instead of relying on this function for installing headers!" )
    endif()
    # 2. Install public headers (and associate them with "DEVELOPMENT" component).
    install( DIRECTORY include/ ${CMAKE_CURRENT_BINARY_DIR}/include/
        TYPE INCLUDE
        COMPONENT ${project_component_prefix_fullname}-Development
        OPTIONAL
    )
endfunction()


##
# @name install_project_targets( [options] component targets... [component targets...]... )
# @brief Installs the given targets for the current project.
# @details The given targets will be installed and associated with the preceding install-component
#          and export-set of the current project. The name of the associated component will be
#          `${project_component_prefix_fullname}-<subcomponent>` and of the associated export-set
#          will be `${project_export_fullname}-<subcomponent>` where `<subcomponent>` is one of
#          `Runtime`, `Development` or `Plugins`.
# @param options Currently only the boolean flag `NO_FOLLOW_ALIAS`. If given, then alias targets
#        will trigger an error (because they cannot be installed directly). If not given, alias
#        targets will be resolved to their real targets and these will be installed.
# @param component The install-component with which the following `targets` will be associated. Must
#        be one of: "RUNTIME", "DEVELOPMENT", "PLUGINS"
# @param targets... The targets (associated with the preceding install-`component`) that will be
#        installed.
# @note The targets that shall be associated with the "PLUGINS" install-component must be of
#       CMake's type `MODULE_LIBRARY`!
# @note The namelink of a shared library, a static library as well as DLL import-libraries on
#       Windows will always be associated with the "DEVELOPMENT" install-component!
# @note Header file-sets will also be associated with the "DEVELOPMENT" install-component unless
#       their targets shall be associated with the "PLUGINS" install-component. Then those headers
#       will be associated with the "PLUGINS" install-component, too.
#
function( install_project_targets )
    cmake_parse_arguments( _luchs
        "NO_FOLLOW_ALIAS"
        ""
        "RUNTIME;DEVELOPMENT;PLUGINS"
        ${ARGN}
    )
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments!" )
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing install-component!" )
    endif()
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments for '${keyword}'!" )
        endforeach()
    endif()
    if ("${project_export_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_export_fullname'!" )
    endif()
    if ("${project_component_prefix_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_prefix_fullname'!" )
    endif()
    # 2. Resolve alias targets?
    if (NOT _luchs_NO_FOLLOW_ALIAS)
        set( runtime_targets )
        foreach( target IN LISTS _luchs_RUNTIME )
            get_target_property( real_target ${target} ALIASED_TARGET )
            if (real_target)
                list( APPEND runtime_targets "${real_target}" )
            else()
                list( APPEND runtime_targets "${target}" )
            endif()
        endforeach()
        set( _luchs_RUNTIME "${runtime_targets}" )
        set( development_targets )
        foreach( target IN LISTS _luchs_DEVELOPMENT )
            get_target_property( real_target ${target} ALIASED_TARGET )
            if (real_target)
                list( APPEND development_targets "${real_target}" )
            else()
                list( APPEND development_targets "${target}" )
            endif()
        endforeach()
        set( _luchs_DEVELOPMENT "${development_targets}" )
        set( plugins_targets )
        foreach( target IN LISTS _luchs_PLUGINS )
            get_target_property( real_target ${target} ALIASED_TARGET )
            if (real_target)
                list( APPEND plugins_targets "${real_target}" )
            else()
                list( APPEND plugins_targets "${target}" )
            endif()
        endforeach()
        set( _luchs_PLUGINS "${plugins_targets}" )
    endif()
    # 3. Install given targets.
    foreach (subcomponent IN ITEMS Runtime Development)
        string( TOUPPER "${subcomponent}" component )
        if (DEFINED _luchs_${component})
            # Supporting file-sets?
            if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.23")
                install( TARGETS ${_luchs_${component}}
                    EXPORT ${project_export_fullname}-${subcomponent}
                    INCLUDES DESTINATION   ${CMAKE_INSTALL_INCLUDEDIR}
                    RUNTIME
                        DESTINATION        ${CMAKE_INSTALL_BINDIR}
                        COMPONENT          ${project_component_prefix_fullname}-${subcomponent}
                    LIBRARY
                        DESTINATION        ${CMAKE_INSTALL_LIBDIR}
                        COMPONENT          ${project_component_prefix_fullname}-${subcomponent}
                        NAMELINK_COMPONENT ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
                    ARCHIVE
                        DESTINATION        ${CMAKE_INSTALL_LIBDIR}
                        COMPONENT          ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
                    OBJECTS
                        DESTINATION        ${CMAKE_INSTALL_LIBDIR}
                        COMPONENT          ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
                    FILE_SET HEADERS
                        DESTINATION        ${CMAKE_INSTALL_INCLUDEDIR}
                        COMPONENT          ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
                )
            else()
                install( TARGETS ${_luchs_${component}}
                    EXPORT ${project_export_fullname}-${subcomponent}
                    INCLUDES DESTINATION   ${CMAKE_INSTALL_INCLUDEDIR}
                    RUNTIME
                        DESTINATION        ${CMAKE_INSTALL_BINDIR}
                        COMPONENT          ${project_component_prefix_fullname}-${subcomponent}
                    LIBRARY
                        DESTINATION        ${CMAKE_INSTALL_LIBDIR}
                        COMPONENT          ${project_component_prefix_fullname}-${subcomponent}
                        NAMELINK_COMPONENT ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
                    ARCHIVE
                        DESTINATION        ${CMAKE_INSTALL_LIBDIR}
                        COMPONENT          ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
                    OBJECTS
                        DESTINATION        ${CMAKE_INSTALL_LIBDIR}
                        COMPONENT          ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
                )
            endif()
        endif()
    endforeach()
    if (DEFINED _luchs_PLUGINS)
        foreach( target IN LISTS _luchs_PLUGINS )
            get_target_property( prop ${target} TYPE )
            if (NOT "${prop}" STREQUAL "MODULE_LIBRARY")
                message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Given target '${target}' shall be associated "
                                    "with the 'PLUGINS' component, but is not a 'MODULE' library (aka plugin)." )
            endif()
        endforeach()
        # Supporting file-sets?
        if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.23")
            install( TARGETS ${_luchs_PLUGINS}
                EXPORT ${project_export_fullname}-Plugins
                LIBRARY  # actually: MODULE_LIBRARY
                    DESTINATION ${CMAKE_INSTALL_BINDIR}/plugins
                    COMPONENT   ${project_component_prefix_fullname}-Plugins
                FILE_SET HEADERS
                    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
                    COMPONENT   ${project_component_prefix_fullname}-Plugins  # Always part of the PLUGINS component!
            )
        else()
            install( TARGETS ${_luchs_PLUGINS}
                EXPORT ${project_export_fullname}-Plugins
                LIBRARY
                    DESTINATION ${CMAKE_INSTALL_BINDIR}/plugins
                    COMPONENT   ${project_component_prefix_fullname}-Plugins
            )
        endif()
    endif()
endfunction()


##
# @name install_project_debugsymbols( targets... )
# @brief Installs debug-symbols files of the given targets for the current project.
# @details The debug-symbols files of the given targets will be installed to the same location
#          where the targets would be installed. Additionally, they will be associated with the
#          "DEBUGSYMBOLS" install-component of the current project, which will be named
#          `${project_component_prefix_fullname}-DebugSymbols`.
# @param targets... The targets whose debug-symbols files will be installed.
# @note This will only be considered for configurations `Debug` and `RelWithDebInfo`.
#
function( install_project_debugsymbols )  # targets...
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments (= target names)!" )
    endif()
    if ("${project_component_prefix_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_prefix_fullname'!" )
    endif()
    foreach( target IN ITEMS ${ARGN} )
        if (NOT TARGET ${target})
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Given argument '${target}' is no valid target!" )
        endif()
    endforeach()
    # 2. Determine the location where to install the associated debug-symbols files.
    set( bin_dir_files )
    set( lib_dir_files )
    set( plugins_dir_files )
    foreach( target IN ITEMS ${ARGN} )
        set( windows_genex "$<$<PLATFORM_ID:Windows>:$<TARGET_PDB_FILE:${target}>>" )
        set( linux_genex   "$<$<PLATFORM_ID:Linux>:$<TARGET_FILE:${target}>.dwp>" )
        get_target_property( prop ${target} TYPE )
        if (prop STREQUAL "EXECUTABLE")
            list( APPEND bin_dir_files "${windows_genex}${linux_genex}" )
        elseif (prop STREQUAL "SHARED_LIBRARY")
            list( APPEND bin_dir_files "${windows_genex}" )
            list( APPEND lib_dir_files "${linux_genex}" )
        elseif (prop STREQUAL "MODULE_LIBRARY")
            list( APPEND plugins_dir_files "${windows_genex}${linux_genex}" )
        elseif (prop STREQUAL "STATIC_LIBRARY")
            # Note: (Real) PDB files cannot be created for static libraries on Windows.
            list( APPEND lib_dir_files "${linux_genex}" )
        else()
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Unsupported type of target '${target}': ${prop}" )
        endif()
    endforeach()
    # 3. Install associated debug-symbols.
    install( FILES     ${bin_dir_files}
        DESTINATION    ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Debug RelWithDebInfo
        COMPONENT      ${project_component_prefix_fullname}-DebugSymbols
        OPTIONAL  # Possibly some debug-symbols files do not exist.
    )
    install( FILES     ${lib_dir_files}
        DESTINATION    ${CMAKE_INSTALL_LIBDIR}
        CONFIGURATIONS Debug RelWithDebInfo
        COMPONENT      ${project_component_prefix_fullname}-DebugSymbols
        OPTIONAL  # Possibly some debug-symbols files do not exist.
    )
    install( FILES     ${plugins_dir_files}
        DESTINATION    ${CMAKE_INSTALL_BINDIR}/plugins
        CONFIGURATIONS Debug RelWithDebInfo
        COMPONENT      ${project_component_prefix_fullname}-DebugSymbols
        OPTIONAL  # Possibly some debug-symbols files do not exist.
    )
endfunction()
