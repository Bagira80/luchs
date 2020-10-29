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
    add_link_options( LINKER:--as-needed,--allow-shlib-undefined )
    # In order to link the sanitizer support libraries automatically, the following option must be suppressed.
    add_link_options( $<$<NOT:$<TARGET_EXISTS:sanitizers>>:LINKER:--no-undefined> )
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
# @name set_default_install_rpath()
# @brief Sets the RPATH that shall be used by default when installing executables/libraries.
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
    # Disable some warnings/errors (again).
    add_compile_options( $<$<CXX_COMPILER_ID:GNU>:-Wno-unknown-pragmas>
                         $<$<CXX_COMPILER_ID:GNU>:-Wno-error=unknown-pragmas>
                         $<$<CXX_COMPILER_ID:Clang>:-Wno-error=zero-length-array>
                         $<$<CXX_COMPILER_ID:Clang>:-Wno-error=return-type-c-linkage>
                         $<$<CXX_COMPILER_ID:GNU,Clang>:-Wunused-result>
                         $<$<CXX_COMPILER_ID:GNU,Clang>:-Wno-error=unused-result> )
    # Treat linker-warnings as errors, too.
    add_link_options( $<$<CXX_COMPILER_ID:GNU,Clang>:LINKER:--fatal-warnings> )
    # Enable detection of violations of the C++ One Definition rule.
    add_link_options( $<$<CXX_COMPILER_ID:GNU,Clang>:LINKER:--detect-odr-violations> )
endfunction()


##
# @name enable_embedding_more_debugging_info()
# @brief Enables embedding more (detailed) debugging information into the compiled artifacts.
# @note These settings have only effect for configurations "Debug" and "RelWithDebInfo".
#
function( enable_embedding_more_debugging_info )
    # Enable more detailed debugging information (optimized for usage with GDB / LLDB).
    add_compile_options( $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-gdwarf-5>
                         $<$<AND:$<CXX_COMPILER_ID:GNU>,$<CONFIG:Debug,RelWithDebInfo>>:-fvar-tracking-assignments>
                         $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-g3>
                         $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-ggdb3> )
    # Enable producing compressed debug sections.
    # Note: This requires a modern linker, like the Gold-linker!
    add_compile_options( $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-gz=zlib> )  # Implies the following linker-option.
    #add_link_options( $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:LINKER:--compress-debug-sections=zlib> )
    # Enable building a GDB index.
    # Note: This requires a modern linker, like the Gold-linker!
    add_compile_options( $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-ggnu-pubnames> )
    add_link_options( $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:LINKER:--gdb-index> )
    # Enable some further optimizations for handling debugging symbols.
    add_compile_options( $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-fdebug-types-section> )
    add_link_options( $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>,$<NOT:$<BOOL:${USE_LLD_LINKER}>>>:LINKER:--strip-debug-gdb> )

    # Strip LTO sections if not compiling with LTO enabled.
    add_link_options( $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>,$<NOT:$<BOOL:${USE_LLD_LINKER}>>,$<NOT:$<BOOL:${ENABLE_LTO}>>>:LINKER:--strip-lto-sections> )
endfunction()


##
# @name optionally_use_sanitizers()
# @brief Setup compiler/linker to use sanitizers if they are enabled.
#
function( optionally_use_sanitizers )
    include( Sanitizers )
    # If any sanitizer shall be enabled extract the related options
    # from target `sanitizers` and apply them globally.
    if (TARGET sanitizers)
        add_compile_options( $<TARGET_PROPERTY:sanitizers,INTERFACE_COMPILE_OPTIONS> )
        add_link_options(    $<TARGET_PROPERTY:sanitizers,INTERFACE_LINK_OPTIONS> )
        if (ORGANIZATION_COMPILER_TAG MATCHES "clang.*" AND NOT USE_LLD_LINKER)
            message( SEND_ERROR "Sanitizers require the LLD linker when used with Clang (in order to work properly)!" )
        endif()
    endif()
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


##
# @name enable_building_with_time_trace()
# @brief Enables generating time-tracing .json files while building.
# @note This cannot be called before the call to the top-most `project` command!
# @note Currently, this is only supported for Clang 11 or newer!
# @note GCC might support this with GCC 11, too. (See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=92396)
#
function( enable_building_with_time_trace )
    if (NOT ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" AND
             "${CMAKE_CXX_COMPILER_VERSION}" VERSION_GREATER_EQUAL "11"))
        message( WARNING "Cannot enable -ftime-trace for current compiler!" )
        unset( ENABLE_BUILDING_WITH_TIME_TRACE CACHE )
        option( ENABLE_BUILDING_WITH_TIME_TRACE "Enable -ftime-trace to generate time tracing .json files." OFF )
    else()
        add_compile_options( $<$<CXX_COMPILER_ID:Clang>:-ftime-trace> )
    endif()
endfunction()
