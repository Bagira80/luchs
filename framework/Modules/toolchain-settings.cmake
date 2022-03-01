##
# @file
# @note This file must be included (indirectly) after the top-level `project` command is called.
# @details This file makes toolchain-specific settings that it reads from the scripts in the
#          subdirectory `ToolchainSettings`, which is located in the same directory as this file.
#

# This file may only be called once and that should be after the top-level `project` command.
include_guard(GLOBAL)

# Verify that this file is included (indirectly) from the top-level CMakeLists.txt file.
if (NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    message( FATAL_ERROR "The current CMake script may only ever be called from the top-level CMakeLists.txt file!" )
endif()


# Load toolchain pre-settings?
if (EXISTS "${LUCHS_TEMPLATES_DIR}/custom/toolchain-pre-settings.cmake.in")
    configure_file( "${LUCHS_TEMPLATES_DIR}/custom/toolchain-pre-settings.cmake.in"
                    "${LUCHS_BINARY_DIR}/toolchain-pre-settings.cmake"
                    NEWLINE_STYLE LF )
    include( "${LUCHS_BINARY_DIR}/toolchain-pre-settings.cmake" )
endif()


# Load Windows specific settings?
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    include( "${CMAKE_CURRENT_LIST_DIR}/ToolchainSettings/windows_specific_settings.cmake" )
endif()
# Load basic output-related settings.
include( "${CMAKE_CURRENT_LIST_DIR}/ToolchainSettings/basic_output_settings.cmake" )
# Load programming-language related settings.
include( "${CMAKE_CURRENT_LIST_DIR}/ToolchainSettings/language_settings.cmake" )
# Load optimization settings.
include( "${CMAKE_CURRENT_LIST_DIR}/ToolchainSettings/optimization_settings.cmake" )


# Use and enforce minimal supported Windows version (on Windows OS)?
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    option( ENFORCE_MINIMAL_SUPPORTED_WINDOWS_VERSION "Enforce a minimal supported Windows version (taken from CMAKE_SYSTEM_VERSION)?" ON )
    mark_as_advanced( ENFORCE_MINIMAL_SUPPORTED_WINDOWS_VERSION )
endif()
if (ENFORCE_MINIMAL_SUPPORTED_WINDOWS_VERSION)
    generate_and_auto_include_targetver_header()
    enforce_minimal_supported_windows_version()
endif()


# Generate MSBuild / Visual Studio project files with Unicode character-set?
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    option( USE_UNICODE_CHARSET "Use the Unicode character-set instead of the Multi-Byte character-set?" ON )
    mark_as_advanced( USE_UNICODE_CHARSET )
endif()
if (USE_UNICODE_CHARSET)
    enable_unicode_charset_globally()
endif()


# Make basic output-related settings.
set_default_library_postfixes()
set_default_binary_suffixes_and_prefixes()
enable_position_independent_code()
set_default_visibility_to_hidden()


# Use default RPATH settings when installing executables/libraries (on Linux OS)?
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    option( USE_DEFAULT_INSTALL_RPATH "Use default RPATH settings when installing executables/libraries." ON )
    mark_as_advanced( USE_DEFAULT_INSTALL_RPATH )
endif()
if (USE_DEFAULT_INSTALL_RPATH)
    set_default_install_rpath()
endif()


# Make programming-language related settings.
set_minimum_required_cxx_standard()
set_minimum_required_c_standard()


# Enable link-time optimization globally?
option( ENABLE_LTO "Enable link-time optimization (LTO)." OFF )
if (ENABLE_LTO)
    enable_link_time_optimization()
endif()


# Load toolchain post-settings?
if (EXISTS "${LUCHS_TEMPLATES_DIR}/custom/toolchain-post-settings.cmake.in")
    configure_file( "${LUCHS_TEMPLATES_DIR}/custom/toolchain-post-settings.cmake.in"
                    "${LUCHS_BINARY_DIR}/toolchain-post-settings.cmake"
                    NEWLINE_STYLE LF )
    include( "${LUCHS_BINARY_DIR}/toolchain-post-settings.cmake" )
endif()
