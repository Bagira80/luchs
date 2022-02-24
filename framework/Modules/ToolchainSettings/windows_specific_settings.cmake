##
# @file
# @details This file defines functions which make Windows specific settings to compiler/linker.
#          * A function that generates the `targetver.h` header and includes it by default.
#          * A function that enforces the minimal supported windows version.
#


##
# @name generate_and_auto_include_targetver_header()
# @brief Generates the header `targetver.h` and automatically includes it when compiling.
# @note This only has any effect when compiling with MSVC or a compiler simulating MSVC.
#
function( generate_and_auto_include_targetver_header )
    if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
        # Generate header but make sure to set required minimal Windows version variable appropriately.
        if (NOT CMAKE_SYSTEM_VERSION)
            message( FATAL_ERROR "Variable CMAKE_SYSTEM_VERSION is not set!" )
        endif()
        string( REGEX REPLACE "^([0-9]+)[.].*"       "\\1" win_major_version "${CMAKE_SYSTEM_VERSION}" )
        string( REGEX REPLACE "^[0-9]+[.]([0-9]+).*" "\\1" win_minor_version "${CMAKE_SYSTEM_VERSION}" )
        message( DEBUG "Using minimal supported Windows version: ${win_major_version}.${win_minor_version}" )
        math( EXPR WINDOWS_VERSION_IN_HEX
            "(${win_major_version} << 8) + ${win_minor_version}"
            OUTPUT_FORMAT HEXADECIMAL )
        configure_file( "${LUCHS_TEMPLATES_DIR}/WindowsPlatform_targetver.h.in"
                        "${CMAKE_BINARY_DIR}/src/targetver.h"
                        NEWLINE_STYLE LF )
        # Automatically include that generated header.
        add_compile_options( "$<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/FI${CMAKE_BINARY_DIR}/src/targetver.h>"
                             "$<$<COMPILE_LANG_AND_ID:C,MSVC>:/FI${CMAKE_BINARY_DIR}/src/targetver.h>"
                             "$<$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},MSVC>>:/FI${CMAKE_BINARY_DIR}/src/targetver.h>"
                             "$<$<AND:$<COMPILE_LANG_AND_ID:C,Clang>,$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},MSVC>>:/FI${CMAKE_BINARY_DIR}/src/targetver.h>"
                             "$<$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},GNU>>:-imacros${CMAKE_BINARY_DIR}/src/targetver.h>"
                             "$<$<AND:$<COMPILE_LANG_AND_ID:C,Clang>,$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},GNU>>:-imacros${CMAKE_BINARY_DIR}/src/targetver.h>"
        )
    endif()
endfunction()


##
# @name enforce_minimal_supported_windows_version()
# @brief Enforce mimimal supported Windows version for executables/DLLs.
# @note This only has any effect when compiling with MSVC or a compiler simulating MSVC.
#
function( enforce_minimal_supported_windows_version )
    if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
        # Calculate required minimal Windows version appropriately.
        if (NOT CMAKE_SYSTEM_VERSION)
            message( FATAL_ERROR "Variable CMAKE_SYSTEM_VERSION is not set!" )
        endif()
        string( REGEX REPLACE "^([0-9]+)[.].*"       "\\1" win_major_version "${CMAKE_SYSTEM_VERSION}" )
        string( REGEX REPLACE "^[0-9]+[.]([0-9]+).*" "\\1" win_minor_version "${CMAKE_SYSTEM_VERSION}" )
        message( DEBUG "Enforcing minimal supported Windows version: ${win_major_version}.${win_minor_version}" )
        # Enforce that minimal supported Windows version when linking.
        add_link_options( "LINKER:SHELL:/SUBSYSTEM:$<IF:$<BOOL:$<TARGET_PROPERTY:WIN32_EXECUTABLE>>,WINDOWS,CONSOLE>,${win_major_version}.${win_minor_version}" )
    endif()
endfunction()
