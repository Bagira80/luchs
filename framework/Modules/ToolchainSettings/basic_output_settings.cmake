##
# @file
# @details This file defines functions/macros which make basic output-related settings for
#          compiling/linking.
#          * A macro that sets the file suffixes/prefixes that should be used by default.
#          * A macro that sets the library postfixes that should be used by default.
#          * A macro for globally enabling compiling into position-independent code (by default).
#          * A macro for globally enabling hidden symbol visibility (by default).
#          * A function which sets the default RPATH that will be set on to-be-installed binaries.
#


##
# @name set_default_binary_suffixes_and_prefixes()
# @brief Sets the suffixes and prefixes that shall be used for built binaries by default.
#
macro( set_default_binary_suffixes_and_prefixes )
    set( CMAKE_SHARED_MODULE_PREFIX "" )
    set( CMAKE_SHARED_MODULE_SUFFIX ".plugin" )
    # Linux (with GCC or Clang)
    if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
        set( CMAKE_EXECUTABLE_SUFFIX     "" )
        set( CMAKE_STATIC_LIBRARY_PREFIX "lib" )
        set( CMAKE_STATIC_LIBRARY_SUFFIX ".a" )
        set( CMAKE_SHARED_LIBRARY_PREFIX "lib" )
        set( CMAKE_SHARED_LIBRARY_SUFFIX ".so" )
        set( CMAKE_IMPORT_LIBRARY_PREFIX "" )
        set( CMAKE_IMPORT_LIBRARY_SUFFIX "" )
        # MinGW / Cygwin (with GCC or Clang)
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows" AND
           (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_SIMULATE_ID STREQUAL "GNU" OR
            CMAKE_C_COMPILER_ID   STREQUAL "GNU" OR CMAKE_C_SIMULATE_ID   STREQUAL "GNU"))
        set( CMAKE_EXECUTABLE_SUFFIX     ".exe" )
        set( CMAKE_STATIC_LIBRARY_PREFIX "lib" )
        set( CMAKE_STATIC_LIBRARY_SUFFIX ".a" )
        set( CMAKE_SHARED_LIBRARY_PREFIX "lib" )
        set( CMAKE_SHARED_LIBRARY_SUFFIX ".dll" )
        set( CMAKE_IMPORT_LIBRARY_PREFIX "lib" )
        set( CMAKE_IMPORT_LIBRARY_SUFFIX ".dll.a" )
    # Windows (with MSVC or Clang)
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Windows" AND
           (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC" OR
            CMAKE_C_COMPILER_ID   STREQUAL "MSVC" OR CMAKE_C_SIMULATE_ID   STREQUAL "MGNU"))
        set( CMAKE_EXECUTABLE_SUFFIX     ".exe" )
        set( CMAKE_STATIC_LIBRARY_PREFIX "" )
        set( CMAKE_STATIC_LIBRARY_SUFFIX ".lib" )
        set( CMAKE_SHARED_LIBRARY_PREFIX "" )
        set( CMAKE_SHARED_LIBRARY_SUFFIX ".dll" )
        set( CMAKE_IMPORT_LIBRARY_PREFIX "" )
        set( CMAKE_IMPORT_LIBRARY_SUFFIX ".dll.lib" )
    # Unsupported platform/compiler
    else()
        message( WARNING "Unknow target-platform ('${CMAKE_SYSTEM_NAME}') and/or compiler ('${CMAKE_CXX_COMPILER_ID}').")
        # Use default file prefixes/suffixes from CMake instead.
    endif()
endmacro()


##
# @name set_default_library_postfixes()
# @brief Sets the config-specific postfixes that shall be used for built libraries by default.
#
macro( set_default_library_postfixes )
    set( CMAKE_DEBUG_POSTFIX          "_dbg" )
    set( CMAKE_MINSIZEREL_POSTFIX     "_small" )
    set( CMAKE_RELEASE_POSTFIX        "" )
    set( CMAKE_RELWITHDEBINFO_POSTFIX "" )  # Same postfix as for 'Release'.
endmacro()


##
# @name enable_position_independent_code()
# @brief Globally enables compiling into position-independent code (by default).
#
macro( enable_position_independent_code )
    set( CMAKE_POSITION_INDEPENDENT_CODE ON )
    set( CMAKE_POLICY_DEFAULT_CMP0083    NEW )
endmacro()


##
# @name set_default_visibility_to_hidden()
# @brief Sets the default visibility settings to hidden.
#
macro( set_default_visibility_to_hidden )
    set( CMAKE_CXX_VISIBILITY_PRESET      hidden )
    set( CMAKE_C_VISIBILITY_PRESET        hidden )
    set( CMAKE_VISIBILITY_INLINES_HIDDEN  ON )
    set( CMAKE_POLICY_DEFAULT_CMP0063     NEW )
endmacro()


##
# @name set_default_install_rpath()
# @brief Sets the RPATH that shall be used by default when installing executables/libraries.
# @note Only has impact on Linux!
#
function( set_default_install_rpath )
    # Calculate relative path from ${CMAKE_INSTALL_BINDIR} to ${CMAKE_INSTALL_LIBDIR}.
    include( GNUInstallDirs )
    file( RELATIVE_PATH relative_path_to_libdir
          ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}
          ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}
    )
    # Use relative RPATH for internal dependencies.
    list( PREPEND CMAKE_INSTALL_RPATH
          "$ORIGIN"
          "$ORIGIN/${relative_path_to_libdir}"
    )
    list( REMOVE_DUPLICATES CMAKE_INSTALL_RPATH )
    set( CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}" PARENT_SCOPE )
    # Use absolute RPATH for external dependencies.
    set( CMAKE_INSTALL_RPATH_USE_LINK_PATH ON PARENT_SCOPE )
endfunction()
