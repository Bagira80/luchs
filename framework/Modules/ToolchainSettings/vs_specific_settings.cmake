##
# @file
# @details This file defines functions which make Visual Studio specific settings to compiler/linker.
#          * A function that generates the common, global property file that will be loaded by each
#            target of a project by default when building with MSBuild / Visual Studio.
#          * A function that generates the custom entry property file `Directory.Build.props` which
#            will be loaded by default when building with MSBuild / Visual Studio.
#          * A function that generates the custom property file `General.Cpp.props` which contains
#            C++ specific settings for MSBuild / Visual Studio.
#          * A function that generates the custom property file `General.CSharp.props` which
#            contains C# specific settings for MSBuild / Visual Studio.
#


include( ex_configure_file )


##
# @name generate_global_project_property_file()
# @brief Generates the common, global property file that will be loaded by each target of a project.
# @note This only has any effect and will only automatically be loaded when building with MSBuild.
#
function( generate_global_project_property_file )
    if (CMAKE_GENERATOR MATCHES "Visual Studio.*")
        ex_configure_file( "${LUCHS_TEMPLATES_DIR}/MSBuildGlobalLuchsSettings.props.in"
                           "${CMAKE_BINARY_DIR}/luchs.MSBuild.Props/GlobalLuchsSettings.props"
                           NEWLINE_STYLE LF )
    endif()
endfunction()


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


##
# @name generate_cxx_property_file()
# @brief Generates the C++ specific property file `General.Cpp.props`.
# @note It will automatically be loaded by `Directory.Build.props` generated by calling function
#       `generate_entry_property_file`.
# @note This only has any effect and will only automatically be loaded when building with MSBuild.
# @note During generation of this file some CMake variables might be evaluated. Make sure to set
#       these before calling this function!
#
function( generate_cxx_property_file )
    if (CMAKE_GENERATOR MATCHES "Visual Studio.*")
        if (EXISTS "${LUCHS_TEMPLATES_DIR}/General.Cpp.props.in")
            ex_configure_file( "${LUCHS_TEMPLATES_DIR}/General.Cpp.props.in"
                               "${CMAKE_BINARY_DIR}/luchs.MSBuild.Props/General.Cpp.props"
                               NEWLINE_STYLE LF )
        endif()
    endif()
endfunction()


##
# @name generate_csharp_property_file()
# @brief Generates the C# specific property file `General.CSharp.props`.
# @note It will automatically be loaded by `Directory.Build.props` generated by calling function
#       `generate_entry_property_file`.
# @note This only has any effect and will only automatically be loaded when building with MSBuild.
# @note During generation of this file some CMake variables might be evaluated. Make sure to set
#       these before calling this function!
#
function( generate_csharp_property_file )
    if (CMAKE_GENERATOR MATCHES "Visual Studio.*")
        if (EXISTS "${LUCHS_TEMPLATES_DIR}/General.CSharp.props.in")
           ex_configure_file( "${LUCHS_TEMPLATES_DIR}/General.CSharp.props.in"
                              "${CMAKE_BINARY_DIR}/luchs.MSBuild.Props/General.CSharp.props"
                              NEWLINE_STYLE LF )
        endif()
    endif()
endfunction()
