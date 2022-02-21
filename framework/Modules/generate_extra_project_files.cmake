##
# @file
# @note This file should (automatically) be included in each CMakeLists.txt file after the
#       `project` command is called and the functions from this file shall then be called.
#


##
# @name generate_extra_project_sources()
# @brief Generates several header and source files for the current project.
# @details This function generates some header and source files:
#          * a header-file containing export-macros for the current project.
#          * a header-file containing function declarations for obtaining the build-configuration
#            of the current project.
#          * a source-file containing the implementation for the functions for obtaining the
#            build-configuration of the current project.
#          * multiple files containing version and resource information of the current project.
# @note This function shall be called after a new project was set up. (The `luchs` framework will
#       automatically take care of this.)
#
function( generate_extra_project_sources )
    include( ex_configure_file )
    # Generate a header-file containing the import/export macros for the current project.
    ex_configure_file( "${LUCHS_TEMPLATES_DIR}/Project_ExportMacros.h.in"
                       "include/${project_folder_fullname}/ExportMacros.h" )
    # Generate a header-file containing the version macros for the current project.
    ex_configure_file( "${LUCHS_TEMPLATES_DIR}/Project_Version.h.in"
                       "src/${project_folder_fullname}/module_info/version.h" )
    # Generate the header-files containing the resource information macros for the current project.
    string( TIMESTAMP THIS_YEAR "%Y" )  # Get the current year as it will be needed during generation.
    ex_configure_file( "${LUCHS_TEMPLATES_DIR}/Project_ResourceInfo.h.in"
                       "src/${project_folder_fullname}/module_info/resource-info_$<CONFIG>.h" )
    # Generate the source-files containing the resource information for the current project.
    ex_configure_file( "${LUCHS_TEMPLATES_DIR}/Project_Resource.rc.in"
                       "src/${project_folder_fullname}/module_info/resource_$<CONFIG>.rc" )
    # Generate header/source-files containing the build-information of the current project.
    ex_configure_file( "${LUCHS_TEMPLATES_DIR}/Project_BuildInfo.hpp.in"
                       "include/${project_folder_fullname}/module_info/BuildInfo.hpp" )
    ex_configure_file( "${LUCHS_TEMPLATES_DIR}/Project_BuildInfo.cpp.in"
                       "src/${project_folder_fullname}/module_info/BuildInfo_$<CONFIG>.cpp" )
endfunction()
