##
# @file
# @details This file defines functions which make Visual Studio specific settings to compiler/linker.
#          * A function that generates the custom entry property file `Directory.Build.props` which
#            will be loaded by default when building with MSBuild / Visual Studio.
#


##
# @name generate_entry_property_file()
# @brief Generates the entry property file `Directory.Build.props`.
# @note This only has any effect and will only automatically be loaded when building with MSBuild.
#
function( generate_entry_property_file )
    if (CMAKE_GENERATOR MATCHES "Visual Studio.*")
        configure_file( "${LUCHS_TEMPLATES_DIR}/Directory.Build.props.in"
                        "${CMAKE_BINARY_DIR}/Directory.Build.props"
                        NEWLINE_STYLE LF )
    endif()
endfunction()
