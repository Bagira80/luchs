##
# @file
# @details Defines several functions for preparing settings of compiler and linker.
#

include_guard()

# Load helper-functions for determining C++ compiler ID and version.
include( "${CMAKE_CURRENT_LIST_DIR}/determine-compiler.cmake" )


##
# @name set_required_build_settings()
# @brief Sets some required compiler/link settings.
#
function( set_required_build_settings )
    # Make sure some required variables are (at least locally) set.
    if (NOT DEFINED CACHE{CMAKE_CXX_COMPILER_ID}  OR
        NOT DEFINED       CMAKE_CXX_COMPILER_ID )
       determine_cxx_compiler_id( CMAKE_CXX_COMPILER_ID )
    endif()
    if (NOT DEFINED CACHE{CMAKE_CXX_COMPILER_VERSION}  OR
        NOT DEFINED       CMAKE_CXX_COMPILER_VERSION)
       determine_cxx_compiler_version( CMAKE_CXX_COMPILER_VERSION )
    endif()

    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        option( USE_LIBC++_INSTEAD_OF_LIBSTDC++ "Use libc++ (instead of libstdc++) as C++ standard-library?" ON )
        mark_as_advanced( USE_LIBC++_INSTEAD_OF_LIBSTDC++ )
    endif()
    if (USE_LIBC++_INSTEAD_OF_LIBSTDC++)
        # Clang should use libc++ as its C++ standard-library.
        add_compile_options( $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-stdlib=libc++> )
        add_link_options(    $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-stdlib=libc++> )
    endif()

    # The linker for the chosen compiler.
    # Note: Clang and GCC 9 (and newer) could use ld.lld, too.
    if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR
        (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 9))
        option( USE_LLD_LINKER "Use LLD-linker (from LLVM)?" FALSE )
        mark_as_advanced( USE_LLD_LINKER )
    endif()
    if (USE_LLD_LINKER)
        add_link_options( $<$<CXX_COMPILER_ID:GNU,Clang>:-fuse-ld=lld> )
        set( CMAKE_LINKER "/usr/bin/ld.lld" CACHE FILEPATH "The linker." FORCE )
    elseif( CMAKE_CXX_COMPILER_ID STREQUAL "GNU" )
        add_link_options( $<$<CXX_COMPILER_ID:GNU>:-fuse-ld=gold> )
        set( CMAKE_LINKER "/usr/bin/ld.gold" CACHE FILEPATH "The linker." FORCE )
    elseif( CMAKE_CXX_COMPILER_ID STREQUAL "Clang" )
        add_link_options( $<$<CXX_COMPILER_ID:Clang>:-fuse-ld=gold> )
        set( CMAKE_LINKER "/usr/bin/ld.gold" CACHE FILEPATH "The linker." FORCE )
    endif()

    # Every executable/library may only link against libraries that
    # it really uses and must resolve all its own dependencies!
    add_link_options( LINKER:--as-needed,--allow-shlib-undefined,--no-undefined )
endfunction()


##
# @name set_minimum_required_cxx_standard()
# @brief Sets the minimal required C++ standard (and disables extensions).
#
macro( set_minimum_required_cxx_standard )
    # Require at least C++17 (and turn off compiler extensions).
    set(CMAKE_CXX_STANDARD          17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS        OFF)
endmacro()


##
# @name set_default_visibility_to_hidden()
# @brief Sets the default visibility settings to hidden.
#
macro( set_default_visibility_to_hidden )
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_CXX_VISIBILITY_HIDDEN ON)
    set(CMAKE_POLICY_DEFAULT_CMP0063 NEW)
endmacro()


##
# @name set_default_binary_suffixes_and_prefixes()
# @brief Sets the suffixes and prefixes that shall be used for generated binaries by default.
#
macro( set_default_binary_suffixes_and_prefixes )
    #set(CMAKE_EXECUTABLE_SUFFIX "")
    #set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
    #set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
    #set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
    #set(CMAKE_STATIC_LIBRARY_SUFFIX ".a")
    set(CMAKE_SHARED_MODULE_PREFIX "organization-")
    set(CMAKE_SHARED_MODULE_SUFFIX ".plugin")
endmacro()


##
# @name set_default_library_postfixes()
# @brief Sets the config-specific postfixes that shall be used for generated libraries by default.
#
macro( set_default_library_postfixes )
    set(CMAKE_DEBUG_POSTFIX "_dbg")
    set(CMAKE_MINSIZEREL_POSTFIX "_small")
    set(CMAKE_RELEASE_POSTFIX "")
    set(CMAKE_RELWITHDEBINFO_POSTFIX "")
endmacro()


##
# @name enable_position_independent_code()
# @brief Enables setting compiler-flags for generating position-independent code by default.
#
macro( enable_position_independent_code )
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    set(CMAKE_POLICY_DEFAULT_CMP0083 NEW)
endmacro()


##
# @name enable_default_warnings_and_errors()
# @brief Enables default-warnings and treats some as hard-errors.
#
function( enable_default_warnings_and_errors )
    # Be pedantic and enforce it by making them errors.
    add_compile_options( $<$<CXX_COMPILER_ID:GNU,Clang>:-pedantic>
                         $<$<CXX_COMPILER_ID:GNU,Clang>:-pedantic-errors>
                         $<$<CXX_COMPILER_ID:GNU,Clang>:-Werror=pedantic> )
    # Enable most common warnings and make (most of) them errors.
    add_compile_options( $<$<CXX_COMPILER_ID:GNU,Clang>:-Wall>
                         $<$<CXX_COMPILER_ID:GNU,Clang>:-Werror=all> )
    add_compile_options( $<$<CXX_COMPILER_ID:GNU,Clang>:-Wextra>
                         $<$<CXX_COMPILER_ID:GNU,Clang>:-Werror=extra> )
    # Treat linker-warnings as errors, too.
    add_link_options( $<$<CXX_COMPILER_ID:GNU,Clang>:LINKER:--fatal-warnings> )
    # Enable detection of violations of the C++ One Definition rule.
    add_link_options( $<$<CXX_COMPILER_ID:GNU,Clang>:LINKER:--detect-odr-violations> )
endfunction()


##
# @name enable_link_time_optimization()
# @brief Enables setting compiler-flags for link-time optimization.
# @note This cannot be called before the call to the top-most `project` command!
#
function( enable_link_time_optimization )
    include(CheckIPOSupported)
    check_ipo_supported(RESULT is_supported OUTPUT error_reason LANGUAGES CXX C)
    if (is_supported)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE PARENT_SCOPE)
    else()
        message(SEND_ERROR "Link-time optimization (LTO/IPO) is not supported: ${error_reason}")
    endif()
endfunction()
