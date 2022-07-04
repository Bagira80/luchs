##
# @file
# @note This file must be included (indirectly) after the top-level `project` command is called.
# @details This file contains different settings for the top-level CMakeLists.txt file.
#          * It loads the CTest module (and thereby creates a CMake option `BUILD_TESTING`).
#          * It sets the MSVC runtime to link against by default on Windows (if not set already).
#          * It sets up the compiler.
#          * It sets up options for enabling different sanitizers and a target `sanitizers` to
#            which other targets need to declare a dependency (via `target_link_libraries`) in
#            order to be compiled with sanitizers support.
#

# This file may only be called once and that should be after the top-level `project` command.
include_guard(GLOBAL)

# Verify that this file is included from the top-level CMakeLists.txt file.
if (NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    message( FATAL_ERROR "The current CMake script may only ever be called from the top-level CMakeLists.txt file!" )
endif()


# Enable support for CTest (and thereby automatically get the `BUILD_TESTING` option).
include( CTest )


# Are we building for Windows but have not already determined which MSVC runtime library to use by default?
if (CMAKE_SYSTEM_NAME STREQUAL "Windows" AND NOT DEFINED CMAKE_MSVC_RUNTIME_LIBRARY)
    # In that case use the dynamic MSVC runtime by default.
    set( CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" )
endif()


# Load and make some compiler-preparations.
include( "${CMAKE_CURRENT_LIST_DIR}/toolchain-settings.cmake" )


# Provide options and target for sanitizers.
include( Sanitizers )


# Create a target for generating API documentation.
if (NOT TARGET apidoc)
    include( create_apidoc_target )
    create_apidoc_target( TARGET_NAME apidoc )
    if (NOT TARGET apidoc)
        message( DEBUG "Unable to find Doxygen. Therefore no `apidoc` target will be created." )
    endif()
endif()


# Add support for meta install-components (for conveniently installing multiple components)?
option( USE_META_INSTALL_COMPONENTS "Add support for meta install-components (\"RUNTIME\", \"DEVELOPMENT\", \"PLUGINS\", \"DEBUGSYMBOLS\")?" ON )
mark_as_advanced( USE_META_INSTALL_COMPONENTS )
if (USE_META_INSTALL_COMPONENTS)
    configure_file( "${LUCHS_TEMPLATES_DIR}/cmake_install.MetaComponents.cmake.in"
                    "${CMAKE_CURRENT_BINARY_DIR}/_luchs/cmake_install.MetaComponents.cmake"
                    @ONLY )
    install( SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/_luchs/cmake_install.MetaComponents.cmake" EXCLUDE_FROM_ALL COMPONENT RUNTIME )
    install( SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/_luchs/cmake_install.MetaComponents.cmake" EXCLUDE_FROM_ALL COMPONENT DEVELOPMENT )
    install( SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/_luchs/cmake_install.MetaComponents.cmake" EXCLUDE_FROM_ALL COMPONENT PLUGINS )
    install( SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/_luchs/cmake_install.MetaComponents.cmake" EXCLUDE_FROM_ALL COMPONENT DEBUGSYMBOLS )
endif()


# Add default options for building specific package types with CPack.
if (NOT CMAKE_CROSSCOMPILING)
    if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        option( CPACK_BINARY_DEB  "Support creating DEB-packages?"  ON )
        option( CPACK_BINARY_RPM  "Support creating RPM-packages?"  OFF )
        option( CPACK_BINARY_STGZ "Support creating STGZ-packages?" OFF )
        option( CPACK_BINARY_TBZ2 "Support creating TBZ2-packages?" OFF )
        option( CPACK_BINARY_TGZ  "Support creating TGZ-packages?"  OFF )
        option( CPACK_BINARY_TXZ  "Support creating TXZ-packages?"  ON )
        option( CPACK_BINARY_TZ   "Support creating TZ-packages?"   OFF )
    endif()
    if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        option( CPACK_BINARY_7Z    "Support creating 7Z-packages?"    OFF )
        option( CPACK_BINARY_NSIS  "Support creating NSIS-packages?"  OFF )
        option( CPACK_BINARY_NUGET "Support creating NUGET-packages?" OFF )
        option( CPACK_BINARY_WIX   "Support creating WIX-packages?"   OFF )
        option( CPACK_BINARY_ZIP   "Support creating ZIP-packages?"   ON )
    endif()
endif()


# Generate main CPack configuration file (in order to get a target called "package") which
# recursively calls all packaging configs from sub-directories to conveniently create all packages.
configure_file( "${LUCHS_TEMPLATES_DIR}/CPackConfig.cmake.in"
                "${CMAKE_CURRENT_BINARY_DIR}/CPackConfig.cmake"
                @ONLY )
