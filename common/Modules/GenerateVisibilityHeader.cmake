##
# @file
# @note This file should be (automatically) included and used in each CMakeLists.txt file for
#       generating a header which helps with symbol visibility of defined (shared) libraries.
#
# @details Provides a macro `generate_visibility_header()` which is a thin wrapper around the
#          macro `generate_export_header()` from CMake's `GenerateExporHeader` module. It
#          internally calls `generate_visibility_header()` with its given parameters but uses
#          more sensible defaults for naming etc.
#

include_guard()


# Load the required module (if not already).
get_directory_property( __currently_defined_macros DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} MACROS )
list( FIND __currently_defined_macros "generate_export_header" __index )
if (__index EQUAL -1)
    include( "GenerateExportHeader" )
endif()
unset( __currently_defined_macros )
unset( __index )


##
# @name generate_visibility_header( target_name VISIBILITY_PREFIX <prefix> [<options>...] )
# @brief Generates a visibility header.
# @param target_name The name of the CMake target (library) for which the visibility header will
#        be generated.
# @param VISIBILITY_PREFIX <prefix> The (mandatory) prefix to be used in the generated header's
#        name and (uppercased) in the contained macros.
#
macro( generate_visibility_header target_name ) # VISIBILITY_PREFIX <prefix> [EXCLUDE_DEPRECATED] [CUSTOM_CONTENT_FROM_VARIABLE <variable>]

    # Parse and prepare arguments.
    cmake_parse_arguments(
        "_"
        "EXCLUDE_DEPRECATED"
        "VISIBILITY_PREFIX;CUSTOM_CONTENT_FROM_VARIABLE"
        ""
        ${ARGN}
    )
    if (NOT DEFINED __VISIBILITY_PREFIX)
        message( FATAL_ERROR "Cannot generate visibility-header! [Reason: \"VISIBILITY_PREFIX\" must be given.]" )
    else ()
        string( MAKE_C_IDENTIFIER "${__VISIBILITY_PREFIX}" __visibility_prefix_identifier )
        string( TOUPPER "${__visibility_prefix_identifier}" __visibility_prefix_identifier_upper )
    endif()
    if (__EXCLUDE_DEPRECATED)
        set( __EXCLUDE_DEPRECATED "DEFINE_NO_DEPRECATED" )
    else ()
        unset( __EXCLUDE_DEPRECATED )
    endif()
    if (DEFINED __CUSTOM_CONTENT_FROM_VARIABLE)
        list( PREPEND __CUSTOM_CONTENT_FROM_VARIABLE "CUSTOM_CONTENT_FROM_VARIABLE" )
    endif()
    if (DEFINED __UNPARSED_ARGUMENTS)
        message( FATAL_ERROR "Cannot generate visibility-header! [Reason: Superfluous arguments were given.]" )
    endif()

    # Generate visibility header.
    generate_export_header(      ${target_name}
        EXPORT_FILE_NAME         "${CMAKE_CURRENT_BINARY_DIR}/include/${__VISIBILITY_PREFIX}_ModuleMacros.h"
        INCLUDE_GUARD_NAME       "${__visibility_prefix_identifier}_ModuleMacros_H"
        PREFIX_NAME              "${__visibility_prefix_identifier_upper}_"
        EXPORT_MACRO_NAME        "DLL_PUBLIC"
        NO_EXPORT_MACRO_NAME     "DLL_PRIVATE"
        DEPRECATED_MACRO_NAME    "DEPRECATED"
        NO_DEPRECATED_MACRO_NAME "NO_DEPRECATED"
        STATIC_DEFINE            "IS_STATIC_LIB"
        ${__EXCLUDE_DEPRECATED}
        ${__CUSTOM_CONTENT_FROM_VARIABLE}
    )

    # Cleanup.
    unset( __visibility_prefix_identifier_upper )
    unset( __visibility_prefix_identifier )
    unset( __VISIBILITY_PREFIX )
    unset( __CUSTOM_CONTENT_FROM_VARIABLE )
    unset( __EXCLUDE_DEPRECATED )

endmacro()

