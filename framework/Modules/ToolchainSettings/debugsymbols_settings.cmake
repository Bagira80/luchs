##
# @file
# @details This file defines functions which modify creation of debug-symbols.
#          * A function that disables separate debug-symbols files.
#


##
# @name disable_separate_debugsymbols()
# @brief Disables creation of debug-symbols in separate files.
#
function( disable_separate_debugsymbols )
    # Disabling this for Windows?
    if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
        # Note: Disabling separate debug-symbols files (*.pdb) for MSVC (or Clang-cl) is not
        #       possible! However, it is possible to make object files (and static libraries?)
        #       contain the debug symbols directly. (But DLLs and executables must still create
        #       separate *.pdb files because they cannot carry debug symbols directly.)
        # See: https://docs.microsoft.com/en-us/cpp/build/reference/debug-generate-debug-info
        if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR
           (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
            add_compile_options( "$<$<AND:$<CXX_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:/Z7>" )
        elseif (CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC" AND
                CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
            # Note: Possibly nothing we can do about it.
        else()
            message( SEND_ERROR "Disabling separate debug symbols (for C++) is not supported for the chosen OS/compiler combination!" )
        endif()
        if (CMAKE_C_COMPILER_ID STREQUAL "MSVC" OR
           (CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
            add_compile_options( "$<$<AND:$<C_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:/Z7>" )
        elseif (CMAKE_C_SIMULATE_ID STREQUAL "MSVC" AND
                CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
            # Note: Possibly nothing we can do about it.
        else()
            message( SEND_ERROR "Disabling separate debug symbols (for C) is not supported for the chosen OS/compiler combination!" )
        endif()
    # Disabling this for Linux?
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
        # Note: Simple, there is nothing to do, this is the default!
    # Disabling this for an unsupported OS?
    else()
        message( FATAL_ERROR "Disabling separate debug symbols is not supported for the chosen OS/compiler combination!" )
    endif()
endfunction()
