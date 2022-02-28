##
# @file
# @details This file defines functions/macros which make basic output-related settings for
#          compiling/linking.
#          * A macro that sets the file suffixes/prefixes that should be used by default.
#          * A macro that sets the library postfixes that should be used by default.
#          * A macro for globally enabling compiling into position-independent code (by default).
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
