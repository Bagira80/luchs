##
# @file
# @note This file should be (automatically) included in each CMakeLists.txt file before the
#       `project` command is called.
#
# @details Includes the file with project-specific information for the currently being processed
#          CMakeLists.txt file. This information contains the projects description, version and
#          other useful information.
#


# Load the project-specific information.
# Note: For each project the project-specific information
#       file must be found in this same relative location.
include( "${CMAKE_CURRENT_SOURCE_DIR}/cmake/project-info.cmake" )
