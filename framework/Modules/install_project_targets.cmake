##
# @file
# @details Defines functions which (help) install headers/targets/debug-symbols for projects.
# @note These functions should be used by each CMakeLists.txt that wants to install its targets.
# @note These functions are extended versions of the `install` commands.
#

include_guard()


include( "GNUInstallDirs" )
# Note: It is recommended to set CMAKE_INSTALL_DOCDIR after each include of GNUInstallDirs!
set( CMAKE_INSTALL_DOCDIR "${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME}" )


##
# @name register_project_targets( component targets... [component targets...]... )
# @brief Registers the given targets with the determined install-component(s) for the current project.
# @details The given targets will be registered and associated with the determined
#          install-component(s) of the current project. The names of these install-component(s)
#          will be `${project_component_prefix_fullname}-<subcomponent>` where `<subcomponent>` is
#          one of `Runtime`, `Development` or `Plugins`.
# @param component The install-component with which the following `targets` will be associated.
#        Must be one of: `RUNTIME`, `DEVELOPMENT`, `PLUGINS`
# @param targets... The names of CMake targets which will be associated with the preceding
#        install-`component`.
# @note  Omitting the `targets` for an install-component is allowed. However, in that case no
#        target will be registered with the corresponding install-component.
# @note Registering a target stores its name in a global property which is named
#       `TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-<subcomponent>`
#       where `<subcomponent> is one of `Runtime`, `Development` or `Plugins`.
# @note Any colons (e.g. `::`) within `${project_component_prefix_fullname}` will **not** be
#       replaced by underscores in the names of the global properties! This makes it more difficult
#       to access these properties (verbatim), but then again these should not be accessed directly
#       anyway.
#
function( register_project_targets )
    cmake_parse_arguments( _luchs
        ""
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
            message( DEBUG "${CMAKE_CURRENT_FUNCTION}: Missing arguments of '${keyword}' for ${PROJECT_NAME}!" )
        endforeach()
    endif()
    if ("${project_component_prefix_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_prefix_fullname'!" )
    endif()
    # 2. Register targets with their component in special global property.
    if (_luchs_RUNTIME)
        set_property( GLOBAL APPEND PROPERTY
            TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Runtime
                ${_luchs_RUNTIME}
        )
    endif()
    if (_luchs_DEVELOPMENT)
        set_property( GLOBAL APPEND PROPERTY
            TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Development
                ${_luchs_DEVELOPMENT}
        )
    endif()
    if (_luchs_PLUGINS)
        set_property( GLOBAL APPEND PROPERTY
            TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Plugins
                ${_luchs_PLUGINS}
        )
    endif()
endfunction()


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
# @name install_project_targets( [options] [component targets...]... )
# @brief Installs the given targets or the already registered ones for the current project.
# @details The given targets will be installed and associated/registered with the preceding
#          install-component and export-set of the current project. The name of the associated
#          install-component will be `${project_component_prefix_fullname}-<subcomponent>` and of
#          the associated export-set will be `${project_export_fullname}-<subcomponent>` where
#          `<subcomponent>` is one of `Runtime`, `Development` or `Plugins`.  
#          If no targets were given then the targets already registered via
#          `register_project_targets` will be installed instead.
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
    if (NOT DEFINED _luchs_RUNTIME AND NOT DEFINED _luchs_DEVELOPMENT AND NOT DEFINED _luchs_PLUGINS)
        # No targets given. Then we should at least have already registered targets.
        message( DEBUG "${CMAKE_CURRENT_FUNCTION}: Using registered targets for project '${PROJECT_NAME}'!" )
        get_cmake_property( runtime_targets     TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Runtime )
        get_cmake_property( development_targets TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Development )
        get_cmake_property( plugins_targets     TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Plugins )
        if (NOT runtime_targets AND NOT development_targets AND NOT plugins_targets)
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments (and no targets already registered with `register_project_targets`)!" )
        endif()
        if (NOT runtime_targets)
            unset( runtime_targets )
        endif()
        if (NOT development_targets)
            unset( development_targets )
        endif()
        if (NOT plugins_targets)
            unset( plugins_targets )
        endif()
        set( use_registered_targets TRUE )
    else()
        set( use_registered_targets FALSE )
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
    # 2. Register targets with their components.
    if (NOT use_registered_targets)
        register_project_targets( RUNTIME ${_luchs_RUNTIME} DEVELOPMENT ${_luchs_DEVELOPMENT} PLUGINS ${_luchs_PLUGINS} )
    else()
        set( _luchs_RUNTIME     ${runtime_targets} )
        set( _luchs_DEVELOPMENT ${development_targets} )
        set( _luchs_PLUGINS     ${plugins_targets} )
    endif()
    # 3. Resolve alias targets?
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
    # 4. Install given targets.
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
# @name install_project_debugsymbols( [targets...] )
# @brief Installs debug-symbols files of the given targets for the current project.
# @details The debug-symbols files of the given targets will be installed to the same location
#          where the targets would be installed. Additionally, they will be associated with the
#          "DEBUGSYMBOLS" install-component of the current project, which will be named
#          `${project_component_prefix_fullname}-DebugSymbols`.  
#          If no targets were given then the debug-symbols of the targets already registered via
#          `register_project_targets` will be installed instead.
# @param targets... The targets whose debug-symbols files will be installed.
# @note This will only be considered for configurations `Debug` and `RelWithDebInfo`.
#
function( install_project_debugsymbols )  # targets...
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        # No targets given. Then we should at least have already registered targets.
        message( DEBUG "${CMAKE_CURRENT_FUNCTION}: Using registered targets for project '${PROJECT_NAME}'!" )
        get_cmake_property( runtime_targets     TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Runtime )
        get_cmake_property( development_targets TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Development )
        get_cmake_property( plugins_targets     TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Plugins )
        if (NOT runtime_targets AND NOT development_targets AND NOT plugins_targets)
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments (and no targets already registered with `register_project_targets`)!" )
        endif()
        # Install debug symbols from registered targets.
        set( targets )
        list( APPEND targets ${runtime_targets} ${development_targets} ${plugins_targets} )
        list( FILTER targets EXCLUDE REGEX "^.*NOTFOUND$" )
        list( REMOVE_DUPLICATES targets )
        set( use_registered_targets ON )
    else()
        # Install debug symbols from given targets.
        set( targets "${ARGN}" )
        set( use_registered_targets OFF )
    endif()
    if ("${project_component_prefix_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_prefix_fullname'!" )
    endif()
    foreach( target IN ITEMS ${targets} )
        if (NOT TARGET ${target})
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Given argument '${target}' is no valid target!" )
        endif()
    endforeach()
    # 2. Determine the location where to install the associated debug-symbols files.
    set( bin_dir_files )
    set( lib_dir_files )
    set( plugins_dir_files )
    foreach( target IN ITEMS ${targets} )
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


##
# @name install_project_grouppackageconfig( name [COMPATIBILITY <mode>] [VERSION <version>] )
# @brief Installs a package-config file for the group-package with the given name.
# @details A package-config file for the group-package with the given name will be generated under
#          the name `${name}Config.cmake` and installed at `<prefix>/lib/cmake/${name}-<version>`.  
#          It contains the logic to find all the package-config files for its bundled components.
#          Those come from all the other projects that bundle themselves with the group-package of
#          the given `name`.
# @param name The name of the group-package for which a package-config file will be installed.
# @param COMPATIBILITY Determines the version-compatibility mode. Must be one of `AnyNewerVersion`,
#        `SameMajorVersion`, `SameMinorVersion` or `ExactVersion`. Defaults to `SameMajorVersion`.
# @param VERSION Determines the version of the group-package. Defaults to `${PROJECT_VERSION}`.
# @note This will be associated with the "DEVELOPMENT" install-component of the current project.
# @note This function must be called before the install-functions of any of the bundled components
#       because this function registers it at some global property
#       (`LUCHS_REGISTRY_GROUP_PACKAGES`) which needs to be accessed by the bundled components when
#       installing.
#
function( install_project_grouppackageconfig name )
    cmake_parse_arguments( _luchs
        ""
        "COMPATIBILITY;VERSION"
        ""
        ${ARGN}
    )
    # 1. Some sanity checks.
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing argument for '${keyword}'!" )
        endforeach()
    endif()
    if (NOT DEFINED _luchs_VERSION OR _luchs_VERSION STREQUAL "")
        set( _luchs_VERSION "${PROJECT_VERSION}" )
    endif()
    if (NOT DEFINED _luchs_COMPATIBILITY)
        set( _luchs_COMPATIBILITY "SameMajorVersion" )
    elseif (NOT _luchs_COMPATIBILITY MATCHES "^(AnyNewer|SameMajor|SameMinor|Exact)Version$" )
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Invalid argument for 'COMPATIBILITY' option! (Only valid "
                            "values are: AnyNewerVersion, SameMajorVersion, SameMinorVersion, ExactVersion)" )
    endif()
    # 1. Generate the package-config for the group-package.
    # Note: This requires the variable `PackageName` to contain the name of the root-package!
    set( PackageName "${name}" )
    configure_file(
        "${LUCHS_TEMPLATES_DIR}/PackageRoot_ImportFile.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/_luchs/${name}-${_luchs_VERSION}.Config.cmake"
        @ONLY
    )
    # 2. Install the generated package-config for the group-package.
    install( FILES "${CMAKE_CURRENT_BINARY_DIR}/_luchs/${name}-${_luchs_VERSION}.Config.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${name}-${_luchs_VERSION}
        RENAME      ${name}Config.cmake
        COMPONENT   ${project_component_prefix_fullname}-Development
    )
    # 3. Generate and install the associated package-config-version file.
    include( CMakePackageConfigHelpers )
    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/_luchs/${name}-${_luchs_VERSION}.ConfigVersion.cmake"
        VERSION       ${_luchs_VERSION}
        COMPATIBILITY ${_luchs_COMPATIBILITY}
    )
    install( FILES "${CMAKE_CURRENT_BINARY_DIR}/_luchs/${name}-${_luchs_VERSION}.ConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${name}-${_luchs_VERSION}
        RENAME      ${name}ConfigVersion.cmake
        COMPONENT   ${project_component_prefix_fullname}-Development
    )
    # 4. Globally register this group-package's name and version.
    set_property( GLOBAL APPEND PROPERTY
        LUCHS_REGISTRY_GROUP_PACKAGES
        "${name}=${_luchs_VERSION}"
    )
endfunction()


##
# @name generate_project_scripts( DEPENDENCY_LOADER|PACKAGE_CONFIG outfile )
# @brief Generates the dependency-loader and/or package-config script for the current project
# @details The denoted script for the current project will be generated under the name and path of
#          the given output-file. It contains information about the targets associated with the
#          "RUNTIME", "DEVELOPMENT" and "PLUGINS" components of the current project.
# @param DEPENDENCY_LOADER denotes that the current project's dependency-loader script shall be
#        generated under the given name. When loaded later (as part of a `find_package`) call it
#        tries to load dependencies of these targets, too.
# @param PACKAGE_CONFIG denotes that the current project's package-config script shall be generated
#        which will later be used by `find_package` to import the exported targets of the current
#        project.
# @param outfile The filename (with path) under which the generated script will be stored.
#
function( generate_project_scripts )
    cmake_parse_arguments( _luchs
        ""
        "DEPENDENCY_LOADER;PACKAGE_CONFIG"
        ""
        ${ARGN}
    )
    # 1. Some sanity checks.
    if (NOT DEFINED _luchs_DEPENDENCY_LOADER AND NOT DEFINED _luchs_PACKAGE_CONFIG)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Neither 'DEPENDENCY_LOADER' nor 'PACKAGE_CONFIG' argument given!" )
    endif()
    if (DEFINED _luchs_DEPENDENCY_LOADER AND DEFINED _luchs_PACKAGE_CONFIG)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Only either 'DEPENDENCY_LOADER' or 'PACKAGE_CONFIG' argument may be given!" )
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Additional, unexpected arguments!" )
    endif()
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing argument for '${keyword}'!" )
        endforeach()
    endif()
    if ("${project_component_prefix_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_prefix_fullname'!" )
    endif()
    if ("${project_export_namespace}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_export_namespace'!" )
    endif()
    # 2. Retrieve list of to-be-exported targets of the "Runtime", "Development" and "Plugins" components of the current project.
    get_cmake_property( runtime_targets     TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Runtime )
    get_cmake_property( development_targets TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Development )
    get_cmake_property( plugins_targets     TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-Plugins )
    set( EXPORTED_TARGETS )
    list( APPEND EXPORTED_TARGETS ${runtime_targets} ${development_targets} ${plugins_targets} )
    list( FILTER EXPORTED_TARGETS EXCLUDE REGEX "^.*NOTFOUND$" )
    # 3. Calculate file/directory-prefix from project's component-prefix.
    string( REPLACE ":" "_" component_file_prefix "${project_component_prefix_fullname}" )
    string( TOLOWER "${component_file_prefix}" lowercase_component_file_prefix )
    # 4. Calculate root namespace.
    string( REPLACE "::" ";" namespace_component_list "${project_export_namespace}" )
    list( GET namespace_component_list 0 ROOT_NAMESPACE )
    # 5. Generate scripts.
    if (DEFINED _luchs_DEPENDENCY_LOADER)
        configure_file(
            "${LUCHS_TEMPLATES_DIR}/Package_ImportFile_DependencyLoader.cmake.in"
            ${_luchs_DEPENDENCY_LOADER}
            @ONLY
        )
    endif()
    if (DEFINED _luchs_PACKAGE_CONFIG)
        configure_file(
            "${LUCHS_TEMPLATES_DIR}/Package_ImportFile.cmake.in"
            ${_luchs_PACKAGE_CONFIG}
            @ONLY
        )
    endif()
endfunction()


##
# @name install_project_exportsets( [component] depsloader... )
# @brief Installs the export-set(s) of the given (or all) component(s) for the current project.
# @details Either the export-set(s) associated with the given component(s) of the current project
#          will be installed or the export-sets of all three components of the current project if
#          no component was explicitly given. The name of the associated export-set must be
#          `${project_export_fullname}-<subcomponent>` where `<subcomponent>` is one of
#          `Runtime`, `Development` or `Plugins`.
# @param component The component whose export-set shall be installed. Must be one of: `RUNTIME`,
#        `DEVELOPMENT`, `PLUGINS`
# @param depsloader The dependency-loader CMake script (associated either with the `component` that
#        came before or associated with all components of the current project) which will be
#        installed as well.
# @note In order for the depsloader script to be automatically loaded when later importing this
#       export set again, we exploit a mechanism that originally only was intended to load
#       additional files with configuration-specific settings. ("Hyrum's Law" says "hi".)
#       However, it is the only (suitable) way to load the depsloader script. :-/
#
function( install_project_exportsets )
    cmake_parse_arguments( _luchs
        ""
        "RUNTIME;DEVELOPMENT;PLUGINS"
        ""
        ${ARGN}
    )
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing arguments!" )
    endif()
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing argument for '${keyword}'!" )
        endforeach()
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        if (${ARGC} EQUAL 1)
            set( _luchs_RUNTIME     ${_luchs_UNPARSED_ARGUMENTS} )
            set( _luchs_DEVELOPMENT ${_luchs_UNPARSED_ARGUMENTS} )
            set( _luchs_PLUGINS     ${_luchs_UNPARSED_ARGUMENTS} )
        else()
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Either give a single dependency-loader script for all components or give one per component. Not both!" )
        endif()
    endif()

    if ("${project_export_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_export_fullname'!" )
    endif()
    if ("${project_export_namespace}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_export_namespace'!" )
    endif()
    if ("${project_component_prefix_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_prefix_fullname'!" )
    endif()
    # 2. Generate the "make-imported-global" scripts.
    foreach (subcomponent IN ITEMS Runtime Development Plugins)
        string( TOUPPER "${subcomponent}" component )
        if (DEFINED _luchs_${component})
            # Retrieve list of to-be-exported targets and generate the script.
            get_cmake_property( EXPORTED_TARGETS TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_prefix_fullname}-${subcomponent} )
            list( FILTER EXPORTED_TARGETS EXCLUDE REGEX "^.*NOTFOUND$" )
            configure_file(
                "${LUCHS_TEMPLATES_DIR}/Package_ImportFile_MakeImportedGlobal.cmake.in"
                "${CMAKE_CURRENT_BINARY_DIR}/_luchs/Package_ImportFile_MakeImportedGlobal.${subcomponent}.cmake"
                @ONLY
            )
        endif()
    endforeach()
    # 3. Calculate file/directory-prefix and destination from project's component-prefix.
    string( REPLACE ":" "_" component_file_prefix "${project_component_prefix_fullname}" )
    set( destination "${CMAKE_INSTALL_LIBDIR}/cmake/${component_file_prefix}-${PROJECT_VERSION}" )
    # 4. Install associated export-sets, "make-imported-global" and "dependency-loader" scripts.
    foreach (subcomponent IN ITEMS Runtime Development)
        string( TOUPPER "${subcomponent}" component )
        if (DEFINED _luchs_${component})
            install( EXPORT ${project_export_fullname}-${subcomponent}
                DESTINATION ${destination}
                FILE        ${component_file_prefix}-${subcomponent}.cmake
                NAMESPACE   ${project_export_namespace}::
                COMPONENT   ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
            )
            install( FILES "${_luchs_${component}}"
                DESTINATION ${destination}
                RENAME      ${component_file_prefix}-${subcomponent}-1000_DepsLoader.cmake
                COMPONENT   ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
            )
            install( FILES  "${CMAKE_CURRENT_BINARY_DIR}/_luchs/Package_ImportFile_MakeImportedGlobal.${subcomponent}.cmake"
                DESTINATION ${destination}
                RENAME      ${component_file_prefix}-${subcomponent}-0010_MakeImportedGlobal.cmake
                COMPONENT   ${project_component_prefix_fullname}-Development  # Always part of the DEVELOPMENT component!
            )
        endif()
    endforeach()
    if (DEFINED _luchs_PLUGINS)
        install( EXPORT ${project_export_fullname}-Plugins
            DESTINATION ${destination}
            FILE        ${component_file_prefix}-Plugins.cmake
            NAMESPACE   ${project_export_namespace}::
            COMPONENT   ${project_component_prefix_fullname}-Plugins
        )
        install( FILES "${_luchs_PLUGINS}"
            DESTINATION ${destination}
            RENAME      ${component_file_prefix}-Plugins-1000_DepsLoader.cmake
            COMPONENT   ${project_component_prefix_fullname}-Plugins
        )
        install( FILES  "${CMAKE_CURRENT_BINARY_DIR}/_luchs/Package_ImportFile_MakeImportedGlobal.Plugins.cmake"
            DESTINATION ${destination}
            RENAME      ${component_file_prefix}-Plugins-0010_MakeImportedGlobal.cmake
            COMPONENT   ${project_component_prefix_fullname}-Plugins
        )
    endif()
endfunction()


##
# @name install_project_packageconfig( configfile [COMPATIBILITY <mode>] [GROUP_PACKAGE <name>] )
# @brief Installs the package-config file for the current project.
# @details The given package-config file for the current project will be installed. Additionally,
#          the associated version file will be generated and installed as well.  
#          If the associated package shall be bundled as a component with another (group-)package,
#          an additional file will be installed to that group-package's directory with information
#          about the bundled package.  
#          All files will be associated with the "DEVELOPMENT" install-component of the current
#          project.
# @param configfile The package-config file for the current project which will be installed
#        together with the associated package-config-version file.
# @param COMPATIBILITY Determines the version-compatibility mode. Must be one of `AnyNewerVersion`,
#        `SameMajorVersion`, `SameMinorVersion` or `ExactVersion`. Defaults to `SameMajorVersion`.
# @param GROUP_PACKAGE The name of the group-package with which the associated package shall be
#        bundled as a component. If not given, the value of the variable
#        `LUCHS_DEFAULT_GROUP_PACKAGE` is taken instead, if it is set. Otherwise the value defaults
#        to `NONE`. The value `NONE` determines that the associated package shall not be bundled
#        with any other package.
# @note A group-package is the package that can be searched for with `find_package` in order to
#       load some or all of its (bundled) components.
#
function( install_project_packageconfig configfile )
    cmake_parse_arguments( _luchs
        ""
        "COMPATIBILITY;GROUP_PACKAGE"
        ""
        ${ARGN}
    )
    # 1. Some sanity checks.
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing argument for '${keyword}'!" )
        endforeach()
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Additional, unexpected arguments!" )
    endif()
    if (NOT DEFINED _luchs_COMPATIBILITY)
        set( _luchs_COMPATIBILITY "SameMajorVersion" )
    elseif (NOT _luchs_COMPATIBILITY MATCHES "^(AnyNewer|SameMajor|SameMinor|Exact)Version$" )
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Invalid argument for 'COMPATIBILITY' option! (Only valid "
                            "values are: AnyNewerVersion, SameMajorVersion, SameMinorVersion, ExactVersion)" )
    endif()
    if (NOT DEFINED _luchs_GROUP_PACKAGE)
        if (DEFINED LUCHS_DEFAULT_GROUP_PACKAGE)
            set( _luchs_GROUP_PACKAGE "${LUCHS_DEFAULT_GROUP_PACKAGE}" )
        else()
            set( _luchs_GROUP_PACKAGE "NONE" )
        endif()
    endif()
    if ("${project_component_prefix_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_prefix_fullname'!" )
    endif()
    if ("${project_component_separator}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_component_separator'!" )
    endif()
    if ("${project_export_fullname}" STREQUAL "")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing variable 'project_export_fullname'!" )
    endif()
    # 2. Calculate file/directory-prefix and destination from project's component-prefix.
    string( REPLACE ":" "_" component_file_prefix "${project_component_prefix_fullname}" )
    string( TOLOWER "${component_file_prefix}" lowercase_component_file_prefix )
    set( destination "${CMAKE_INSTALL_LIBDIR}/cmake/${component_file_prefix}-${PROJECT_VERSION}" )
    # 3. Install associated package-config file.
    install( FILES "${configfile}"
        DESTINATION ${destination}
        RENAME      ${lowercase_component_file_prefix}-config.cmake
        COMPONENT   ${project_component_prefix_fullname}-Development
    )
    # 4. Generate and install associated package-config-version file.
    include( CMakePackageConfigHelpers )
    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/_luchs/${component_file_prefix}.config-version.cmake"
        COMPATIBILITY ${_luchs_COMPATIBILITY}
    )
    install( FILES "${CMAKE_CURRENT_BINARY_DIR}/_luchs/${component_file_prefix}.config-version.cmake"
        DESTINATION ${destination}
        RENAME      ${lowercase_component_file_prefix}-config-version.cmake
        COMPONENT   ${project_component_prefix_fullname}-Development
    )
    # 5. Bundle it with some group-package?
    if (NOT _luchs_GROUP_PACKAGE STREQUAL "NONE")
        # Extract version of the group-package with which to bundle.
        get_property( registered_group_packages GLOBAL PROPERTY LUCHS_REGISTRY_GROUP_PACKAGES )
        list( FILTER registered_group_packages INCLUDE REGEX "^${_luchs_GROUP_PACKAGE}=.+" )
        list( REMOVE_DUPLICATES registered_group_packages )
        list( LENGTH registered_group_packages length )
        if (length EQUAL 0)
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Group-package '${_luchs_GROUP_PACKAGE}' has not been registered before! "
                                "(Make sure to call 'install_project_grouppackageconfig(${luchs_GROUP_PACKAGE})' before.)" )
        elseif (length GREATER 1)
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Group-package '${_luchs_GROUP_PACKAGE}' has been registered more than once before! "
                                "(Make sure to call 'install_project_grouppackageconfig(${luchs_GROUP_PACKAGE})' only once before.)" )
        endif()
        string( REGEX REPLACE "^${_luchs_GROUP_PACKAGE}=(.+)$" "\\1" group_package_version "${registered_group_packages}" )
        if ("${group_package_version}" STREQUAL "")
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Unable to retrieve version number of group-package '${_luchs_GROUP_PACKAGE}'!" )
        endif()
        # Generate the file containing information about the current project's package that shall be bundled with the group-package.
        set( content "set(BUNDLED_COMPONENT_NAME \"@project_component_prefix_fullname@\")"
                     "set(BUNDLED_COMPONENT_NAME_SEPARATOR \"@project_component_separator@\")"
                     "set(BUNDLED_COMPONENT_SEARCH_NAME \"@component_file_prefix@\")"
                     "set(BUNDLED_COMPONENT_VERSION \"@PROJECT_VERSION@\")"
                     "set(BUNDLED_COMPONENT_EXPORTNAME \"@project_export_fullname@\")"
        )
        list( JOIN content "\n" content )
        file( CONFIGURE
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/_luchs/${component_file_prefix}.BundledComponent.cmake"
            CONTENT "${content}"
            @ONLY NEWLINE_STYLE LF
        )
        # Determine the name of the information file that shall be installed to the group-package's (install-)directory.
        # Note: If the group-package's name equals the first part of the current project's component prefix
        #       (when ignoring case) then strip it from the name for the information file.
        string( FIND "${project_component_prefix_fullname}" "${project_component_separator}" index )
        if (NOT index EQUAL -1)
            string( SUBSTRING "${project_component_prefix_fullname}" 0 ${index} first_component )
            string( TOLOWER "${first_component}" lowercase_first_component )
            string( TOLOWER "${_luchs_GROUP_PACKAGE}" lowercase_group_package )
            if (lowercase_group_package STREQUAL lowercase_first_component)
                string( LENGTH "${project_component_separator}" length )
                math( EXPR index "${index} + ${length}" )
                string( SUBSTRING "${project_component_prefix_fullname}" ${index} -1 remaining_component )
                string( REPLACE ":" "_" lowercase_component_file_prefix "${remaining_component}" )
                string( TOLOWER "${lowercase_component_file_prefix}" lowercase_component_file_prefix )
            endif()
        endif()
        # Install information file into group-package's (install-)directory.
        install( FILES "${CMAKE_CURRENT_BINARY_DIR}/_luchs/${component_file_prefix}.BundledComponent.cmake"
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${_luchs_GROUP_PACKAGE}-${group_package_version}/components
            RENAME      ${lowercase_component_file_prefix}.BundledComponent.cmake
            COMPONENT   ${project_component_prefix_fullname}-Development
        )
    endif()
endfunction()
