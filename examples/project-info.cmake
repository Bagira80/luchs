##
# @file
# @note This file should (automatically) be included before calling the `project` command in the
#       associated CMakeLists.txt file. (This is automatically taken care of by the
#       `common-project-pre-actions.cmake` script.)
#
# @details Contains project-specific information for the currently being processed CMakeLists.txt
#          file. This information contains the project description, version and other useful
#          information.
#


## General information about the current project.
##

# Fixed project information.
set( project_name        "Company.Example" )
set( project_namespace   "company::example" )
set( project_description "An example project for a luchs based project." )
set( project_homepage    "https://github.com/Bagira80/luchs.git" )

# Project version.
set( project_version "1.0.0" )

# Other project-specific settings.
# ...
