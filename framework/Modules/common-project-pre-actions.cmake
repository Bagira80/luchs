##
# @file
# @note This file should (automatically) be included in each CMakeLists.txt file before the
#       `project` command is called.
#
# @details Includes the file with project-specific information for the currently being processed
#          CMakeLists.txt file. This information contains the project's description, version and
#          other useful information.  
#          Additionally, tries to load a file with company-specific information for the entire
#          CMake build if it had not been loaded already. If none can be found a new one will be
#          generated and loaded instead (if a suitable template exists).
# @note The file with the project-specific information needs to be named `project-info.cmake` and
#       must be located in a subdirectory `cmake` of the currently being processed CMakeLists.txt
#       file.
# @note The file with the company-specific information needs to be named `company-info.cmake` and
#       must be located in a subdirectory `cmake` of the currently being processed CMakeLists.txt
#       file, if it exists at all. A suitable template must be named `company-info.cmake.in` and
#       will be searched for in this CMake framework's `templates` directory.
#


# Load the company-specific information (if not already).
# Note: If no such information file can be loaded, generate one and load that instead.
if (NOT COMPANY_INFO_LOADED)
    include( "${CMAKE_CURRENT_SOURCE_DIR}/luchs/company-info.cmake" OPTIONAL
             RESULT_VARIABLE COMPANY_INFO_LOADED )
    if (NOT COMPANY_INFO_LOADED)
        if (EXISTS "${LUCHS_TEMPLATES_DIR}/company-info.cmake.in")
            configure_file( "${LUCHS_TEMPLATES_DIR}/company-info.cmake.in"
                            "${CMAKE_CURRENT_BINARY_DIR}/luchs/company-info.cmake"
                            COPYONLY )
            include( "${CMAKE_CURRENT_BINARY_DIR}/luchs/company-info.cmake"
                     RESULT_VARIABLE COMPANY_INFO_LOADED )
        else()
            message( DEBUG "Can neither load nor generate a 'company-info.cmake' file for directory: ${CMAKE_CURRENT_SOURCE_DIR}" )
            set( COMPANY_ID                   "Unknown" )
            set( COMPANY_NAME                 "Unknown" )
            set( COMPANY_FOUNDING_YEAR        "?" )
            set( COMPANY_WEBSITE              "" )
            set( COMPANY_EMAIL                "unknown@unknown" )
            set( COMPANY_SUPPORT_EMAIL        "unknown@unknown" )
            set( COMPANY_SUPPORT_NAME         "Support Team" )
            set( COMPANY_GROUP_PACKAGE_NAME   "unknown" )
        endif()
    endif()
endif()


# Load the project-specific information.
# Note: For each project the project-specific information
#       file must be found in this same relative location.
include( "${CMAKE_CURRENT_SOURCE_DIR}/luchs/project-info.cmake" )
