##
# @file
# @note This file should (automatically) be included in each CMakeLists.txt file before the
#       `project` command is called.
#
# @details Includes the file with project-specific information for the currently being processed
#          CMakeLists.txt file. This information contains the project's description, version and
#          other useful information.
# @note The file with the project-specific information needs to be named `project-info.cmake` and
#       must be located in a subdirectory `cmake` of the currently being processed CMakeLists.txt
#       file.
#


# Load the project-specific information.
# Note: For each project the project-specific information
#       file must be found in this same relative location.
include( "${CMAKE_CURRENT_SOURCE_DIR}/luchs/project-info.cmake" )
