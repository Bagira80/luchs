##
# @file
# @details Defines macros and functions which help installing targets, files and export files.
#          This file needs to be included from each CMakeLists.txt that wants to install its
#          targets etc.
#

include_guard()



include( "GNUInstallDirs" )
# Note: It is recommended to set CMAKE_INSTALL_DOCDIR after each include of GNUInstallDirs!
set( CMAKE_INSTALL_DOCDIR "${CMAKE_INSTALL_DATAROOTDIR}/doc/${PROJECT_NAME}" )


##
# @name generate_depsloader_script( outfile )
# @brief Generates the dependency-loader script for the current project.
# @details The dependency-loader script for the current project will be generated under the name
#          of the given output-file. It contains information about the targets associated with
#          the "Runtime" and the "Development" component of the current project. When loaded
#          later (as part of a `find_package`) call it tries to load the (ORGANIZATION) dependencies
#          of these targets, too.
# @param outfile The filename (with path) under which the generated script will be stored.
#
function( generate_depsloader_script outfile )
    # 1. Some sanity checks.
    if (NOT (${ARGC} EQUAL 1))
        message( SEND_ERROR "generate_depsloader_script: Additional, unexpected arguments!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "generate_depsloader_script: Missing variable 'project_component_fullname'!" )
    endif()
    # 2. Retrieve list of to-be-exported targets of the "Runtime" and "Development" components of the current project.
    get_cmake_property( EXPORTED_TARGETS TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_fullname}-Runtime )
    get_cmake_property( MORE_EXPORTED_TARGETS TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_fullname}-Development )
    list( APPEND EXPORTED_TARGETS ${MORE_EXPORTED_TARGETS} )
    list( FILTER EXPORTED_TARGETS EXCLUDE REGEX "^.*NOTFOUND$" )
    # 3. Generate dependency-loader script.
    configure_file(
        "${ORGANIZATION_TEMPLATES_DIR}/Module_ExportFile_DependencyLoader.cmake.in"
        ${outfile}
        @ONLY
    )
endfunction()


##
# @name generate_package_configfile( outfile )
# @brief Generates the package config-file for the current project.
# @details The package config-file for the current project will be generated under the name of
#          the given output-file. It contains information about the targets associated with the
#          "Runtime" and the "Development" component of the current project. It can be found by
#          a call to `find_package` and provides the associated targets,
# @param outfile The filename (with path) under which the generated file will be stored.
#
function( generate_package_configfile outfile )
    # 1. Some sanity checks.
    if (NOT (${ARGC} EQUAL 1))
        message( SEND_ERROR "generate_package_configfile: Additional, unexpected arguments!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "generate_package_configfile: Missing variable 'project_component_fullname'!" )
    endif()
    # 2. Retrieve list of to-be-exported targets of the "Runtime" and "Development" components of the current project.
    get_cmake_property( EXPORTED_TARGETS TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_fullname}-Runtime )
    get_cmake_property( MORE_EXPORTED_TARGETS TARGETS_ASSOCIATED_WITH_COMPONENT_${project_component_fullname}-Development )
    list( APPEND EXPORTED_TARGETS ${MORE_EXPORTED_TARGETS} )
    list( FILTER EXPORTED_TARGETS EXCLUDE REGEX "^.*NOTFOUND$" )
    # 3. Generate package config-file.
    configure_file(
        "${ORGANIZATION_TEMPLATES_DIR}/Module_ExportFile.cmake.in"
        ${outfile}
        @ONLY
    )
endfunction()


##
# @name install_plugin_targets( targets... )
# @brief Installs the given plugin targets as part of the "Runtime" component for the current project.
# @details The given targets will be installed and associated with the "Runtime" export-set of
#          the current project. The name of the associated export-set will be
#          "${project_export_fullname}-Runtime".
# @param targets... The names of CMake plugin targets which will be installed.
#
macro( install_plugin_targets )  # targets...
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "install_plugin_targets: Missing arguments (= target names)!" )
    endif()
    if ("${project_export_fullname}" STREQUAL "")
        message( SEND_ERROR "install_plugin_targets: Missing variable 'project_export_fullname'!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_plugin_targets: Missing variable 'project_component_fullname'!" )
    endif()
    # 2. Install given targets.
    install( TARGETS ${ARGN}
        EXPORT ${project_export_fullname}-Runtime
        DESTINATION ${CMAKE_INSTALL_BINDIR}/plugins
        COMPONENT   ${project_component_fullname}-Runtime
    )
endmacro()


##
# @name install_runtime_targets( targets... )
# @brief Installs the given targets as part of the "Runtime" component for the current project.
# @details The given targets will be installed and associated with the "Runtime" export-set of
#          the current project. The name of the associated export-set will be
#          "${project_export_fullname}-Runtime".
# @param targets... The names of CMake targets which will be installed.
# @note The namelink of a shared library will be associated with the "Development" component!
#
macro( install_runtime_targets )  # targets...
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "install_runtime_targets: Missing arguments (= target names)!" )
    endif()
    if ("${project_export_fullname}" STREQUAL "")
        message( SEND_ERROR "install_runtime_targets: Missing variable 'project_export_fullname'!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_runtime_targets: Missing variable 'project_component_fullname'!" )
    endif()
    # 2. Install given targets.
    install( TARGETS ${ARGN}
        EXPORT ${project_export_fullname}-Runtime
        COMPONENT              ${project_component_fullname}-Runtime
        INCLUDES DESTINATION   ${CMAKE_INSTALL_INCLUDEDIR}
        RUNTIME
            DESTINATION        ${CMAKE_INSTALL_BINDIR}
            COMPONENT          ${project_component_fullname}-Runtime
        LIBRARY
            DESTINATION        ${CMAKE_INSTALL_LIBDIR}
            COMPONENT          ${project_component_fullname}-Runtime
            NAMELINK_COMPONENT ${project_component_fullname}-Development
        ARCHIVE
            DESTINATION        ${CMAKE_INSTALL_LIBDIR}
            COMPONENT          ${project_component_fullname}-Runtime
    )
endmacro()


##
# @name install_development_targets( targets... )
# @brief Installs the given targets as part of the "Development" component for the current project.
# @details The given targets will be installed and associated with the "Development" export-set of
#          the current project. The name of the associated export-set will be
#          "${project_export_fullname}-Development".
# @param targets... The names of CMake targets which will be installed.
#
macro( install_development_targets )  # targets...
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "install_development_targets: Missing arguments (= target names)!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_development_targets: Missing variable 'project_component_fullname'!" )
    endif()
    if ("${project_export_fullname}" STREQUAL "")
        message( SEND_ERROR "install_development_targets: Missing variable 'project_export_fullname'!" )
    endif()
    # 2. Install given targets.
    install( TARGETS ${ARGN}
        EXPORT ${project_export_fullname}-Development
        COMPONENT              ${project_component_fullname}-Development
        INCLUDES DESTINATION   ${CMAKE_INSTALL_INCLUDEDIR}
        RUNTIME
            DESTINATION        ${CMAKE_INSTALL_BINDIR}
            COMPONENT          ${project_component_fullname}-Development
        LIBRARY
            DESTINATION        ${CMAKE_INSTALL_LIBDIR}
            COMPONENT          ${project_component_fullname}-Development
            NAMELINK_COMPONENT ${project_component_fullname}-Development
        ARCHIVE
            DESTINATION        ${CMAKE_INSTALL_LIBDIR}
            COMPONENT          ${project_component_fullname}-Development
    )
endmacro()


##
# @name install_plugin_debugsymbols_files( files... )
# @brief Installs the given files as part of the "DebugSymbols" component for the current project.
# @details The given files will be installed and associated with the "DebugSymbols" export-set of
#          the current project. They will be installed into the destination for plugins. The
#          name of the associated export-set will be "${project_export_fullname}-DebugSymbols".
# @param files... The files (with debugging symbols) which will be installed.
# @note This will only be considered for configurations "Debug" and "RelWithDebInfo".
#
macro( install_plugin_debugsymbols_files )  # files...
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "install_debugsymbols_files: Missing arguments (= debug-symbol files)!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_debugsymbols_files: Missing variable 'project_component_fullname'!" )
    endif()
    # 2. Install given files.
    install( FILES     ${ARGN}
        DESTINATION    ${CMAKE_INSTALL_BINDIR}/plugins
        CONFIGURATIONS Debug RelWithDebInfo
        COMPONENT      ${project_component_fullname}-DebugSymbols
    )
endmacro()


##
# @name install_library_debugsymbols_files( files... )
# @brief Installs the given files as part of the "DebugSymbols" component for the current project.
# @details The given files will be installed and associated with the "DebugSymbols" export-set of
#          the current project. They will be installed into the destination for libraries. The
#          name of the associated export-set will be "${project_export_fullname}-DebugSymbols".
# @param files... The files (with debugging symbols) which will be installed.
# @note This will only be considered for configurations "Debug" and "RelWithDebInfo".
#
macro( install_library_debugsymbols_files )  # files...
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "install_debugsymbols_files: Missing arguments (= debug-symbol files)!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_debugsymbols_files: Missing variable 'project_component_fullname'!" )
    endif()
    # 2. Install given files.
    install( FILES     ${ARGN}
        DESTINATION    ${CMAKE_INSTALL_LIBDIR}
        CONFIGURATIONS Debug RelWithDebInfo
        COMPONENT      ${project_component_fullname}-DebugSymbols
    )
endmacro()


##
# @name install_executable_debugsymbols_files( files... )
# @brief Installs the given files as part of the "DebugSymbols" component for the current project.
# @details The given files will be installed and associated with the "DebugSymbols" export-set of
#          the current project. They will be installed into the destination for executables. The
#          name of the associated export-set will be "${project_export_fullname}-DebugSymbols".
# @param files... The files (with debugging symbols) which will be installed.
# @note This will only be considered for configurations "Debug" and "RelWithDebInfo".
#
macro( install_executable_debugsymbols_files )  # files...
    # 1. Some sanity checks.
    if (${ARGC} EQUAL 0)
        message( SEND_ERROR "install_debugsymbols_files: Missing arguments (= debug-symbol files)!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_debugsymbols_files: Missing variable 'project_component_fullname'!" )
    endif()
    # 2. Install given files.
    install( FILES     ${ARGN}
        DESTINATION    ${CMAKE_INSTALL_BINDIR}
        CONFIGURATIONS Debug RelWithDebInfo
        COMPONENT      ${project_component_fullname}-DebugSymbols
    )
endmacro()


##
# @name install_runtime_exportset( depsloader )
# @brief Installs the export-set of the "Runtime" component for the current project.
# @details The export-set associated with the "Runtime" component of the current project will
#          be installed. The name of the associated export-set must be
#          "${project_export_fullname}-Runtime".
# @param depsloader The CMake script which should be able to load the (ORGANIZATION) dependencies of
#        the targets associated with the "Runtime" component. It will be installed, too.
# @note In order for the depsloader script to be automatically loaded when later importing this
#       export set again, we exploit a mechanism that originally only was intended to load
#       additional files with configuration-specific settings. ("Hyrum's Law" says "hi".)
#       However, it is the only (suitable) way to load the depsloader script. :-/
#
macro( install_runtime_exportset depsloader )
    # 1. Some sanity checks.
    if (NOT (${ARGC} EQUAL 1))
        message( SEND_ERROR "install_runtime_exportset: Additional, unexpected arguments!" )
    endif()
    if ("${package_group_dirname}" STREQUAL "")
        message( SEND_ERROR "install_runtime_exportset: Missing variable 'package_group_dirname'!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_runtime_exportset: Missing variable 'project_component_fullname'!" )
    endif()
    if ("${project_export_fullname}" STREQUAL "")
        message( SEND_ERROR "install_runtime_exportset: Missing variable 'project_export_fullname'!" )
    endif()
    if ("${project_export_namespace}" STREQUAL "")
        message( SEND_ERROR "install_runtime_exportset: Missing variable 'project_export_namespace'!" )
    endif()
    if ("${project_output_fullname}" STREQUAL "")
        message( SEND_ERROR "install_runtime_exportset: Missing variable 'project_output_fullname'!" )
    endif()
    # 2. Install associated export-set.
    install( EXPORT ${project_export_fullname}-Runtime
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${package_group_dirname}/${project_output_fullname}
        FILE        ${project_output_fullname}-Runtime.cmake
        NAMESPACE   ${project_export_namespace}::
        COMPONENT   ${project_component_fullname}-Runtime
    )
    # 3. Install associated dependency-loader script.
    install( FILES "${depsloader}"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${package_group_dirname}/${project_output_fullname}
        RENAME      ${project_output_fullname}-Runtime--DepsLoader.cmake
        COMPONENT   ${project_component_fullname}-Runtime
    )
endmacro()


##
# @name install_development_exportset( depsloader )
# @brief Installs the export-set of the "Development" component for the current project.
# @details The export-set associated with the "Development" component of the current project will
#          be installed. The name of the associated export-set must be
#          "${project_export_fullname}-Development".
# @param depsloader The CMake script which should be able to load the (ORGANIZATION) dependencies of
#        the targets associated with the "Development" component. It will be installed, too.
# @note In order for the depsloader script to be automatically loaded when later importing this
#       export set again, we exploit a mechanism that originally only was intended to load
#       additional files with configuration-specific settings. ("Hyrum's Law" says "hi".)
#       However, it is the only (suitable) way to load the depsloader script. :-/
#
macro( install_development_exportset depsloader )
    # 1. Some sanity checks.
    if (NOT (${ARGC} EQUAL 1))
        message( SEND_ERROR "install_development_exportset: Additional, unexpected arguments!" )
    endif()
    if ("${package_group_dirname}" STREQUAL "")
        message( SEND_ERROR "install_development_exportset: Missing variable 'package_group_dirname'!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_development_exportset: Missing variable 'project_component_fullname'!" )
    endif()
    if ("${project_export_fullname}" STREQUAL "")
        message( SEND_ERROR "install_development_exportset: Missing variable 'project_export_fullname'!" )
    endif()
    if ("${project_export_namespace}" STREQUAL "")
        message( SEND_ERROR "install_development_exportset: Missing variable 'project_export_namespace'!" )
    endif()
    if ("${project_output_fullname}" STREQUAL "")
        message( SEND_ERROR "install_development_exportset: Missing variable 'project_output_fullname'!" )
    endif()
    # 2. Install associated export-set.
    install( EXPORT ${project_export_fullname}-Development
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${package_group_dirname}/${project_output_fullname}
        FILE        ${project_output_fullname}-Development.cmake
        NAMESPACE   ${project_export_namespace}::
        COMPONENT   ${project_component_fullname}-Development
    )
    # 3. Install associated dependency-loader script.
    install( FILES "${depsloader}"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${package_group_dirname}/${project_output_fullname}
        RENAME      ${project_output_fullname}-Development--DepsLoader.cmake
        COMPONENT   ${project_component_fullname}-Development
    )
endmacro()


##
# @name install_package_configfile( configfile )
# @brief Installs the package config file for the current project.
# @details The package config file of the current project will be installed. Its name will be
#          "${project_component_fullname}-config.cmake". Additionally, the associated version
#          file "${project_component_fullname}-config-version.cmake" will be generated and also
#          installed. Both will be associated with the "Runtime" component of the current
#          project
# @param configfile The package configuration file for the current project which will be installed
#        together with the associated version file.
#
macro( install_package_configfile configfile )
    # 1. Some sanity checks.
    if (NOT (${ARGC} EQUAL 1))
        message( SEND_ERROR "install_package_configfile: Additional, unexpected arguments!" )
    endif()
    if ("${package_group_dirname}" STREQUAL "")
        message( SEND_ERROR "install_package_configfile: Missing variable 'package_group_dirname'!" )
    endif()
    if ("${project_component_fullname}" STREQUAL "")
        message( SEND_ERROR "install_package_configfile: Missing variable 'project_component_fullname'!" )
    endif()
    if ("${project_output_fullname}" STREQUAL "")
        message( SEND_ERROR "install_package_configfile: Missing variable 'project_output_fullname'!" )
    endif()
    # 2. Install associated package config-file.
    install( FILES "${configfile}"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${package_group_dirname}/${project_output_fullname}
        RENAME      ${project_output_fullname}-config.cmake
        COMPONENT   ${project_component_fullname}-Runtime
    )
    # 3. Generate and install associated package config version file.
    include( CMakePackageConfigHelpers )
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${project_output_fullname}-config-version.cmake
        COMPATIBILITY SameMajorVersion
    )
    install( FILES "${CMAKE_CURRENT_BINARY_DIR}/${project_output_fullname}-config-version.cmake"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${package_group_dirname}/${project_output_fullname}
        COMPONENT   ${project_component_fullname}-Runtime
    )
endmacro()
