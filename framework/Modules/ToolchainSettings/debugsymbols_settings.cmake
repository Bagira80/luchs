##
# @file
# @details This file defines functions which modify creation of debug-symbols.
#          * A function that disables separate debug-symbols files.
#          * A function that enables separate debug-symbols files.
#          * An associated helper function that registers post-build actions for build targets
#            to create the separate debug-symbols files.
#


##
# @name disable_separate_debugsymbols()
# @brief Disables creation of debug-symbols in separate files.
#
function( disable_separate_debugsymbols )
    # Disabling this for Windows?
    if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
        # First determine if a specific CMake setting shall be used for MSVC and compatible compilers.
        if (POLICY CMP0141)
            cmake_policy( GET CMP0141 use_modern_way )
            if (use_modern_way STREQUAL "NEW")
                set( use_modern_way "TRUE" )
            else()
                set( use_modern_way "FALSE" )
            endif()
        endif()
        # Note: Disabling separate debug-symbols files (*.pdb) for libraries or executables created
        #       by MSVC (or Clang-cl) is not possible. One can only drop debug information entirely
        #       (which is not what we want here).  
        #       However, it is at least possible to make object files (and static libraries) that
        #       contain the debug symbols directly. (But DLLs and executables must still create
        #       separate *.pdb files because they cannot carry debug symbols directly.)
        # See: https://docs.microsoft.com/en-us/cpp/build/reference/debug-generate-debug-info
        if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR
           (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
            if (use_modern_way)
                set( CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<AND:$<CXX_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:Embedded>")
            else()
                add_compile_options( "$<$<AND:$<CXX_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:/Z7>" )
            endif()
        elseif (CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC" AND
                CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
            # Note: Possibly nothing we can do about it.
        else()
            message( SEND_ERROR "Disabling separate debug symbols (for C++) is not supported for the chosen OS/compiler combination!" )
        endif()
        if (CMAKE_C_COMPILER_ID STREQUAL "MSVC" OR
           (CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
            if (use_modern_way)
                set( CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<AND:$<C_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:Embedded>")
            else()
                add_compile_options( "$<$<AND:$<C_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:/Z7>" )
            endif()
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


##
# @name enable_separate_debugsymbols( only_after_linking )
# @brief Enables and configures creation of debug-symbols in separate files.
# @param only_after_linking Determines if splitting debug-symbols into separate files only after
#        linking or already do so when compiling object files.
# @note The argument must be set to `true` if link-time-optimization is used!
# @note These are only generated for configurations "Debug" and "RelWithDebInfo".
#
function( enable_separate_debugsymbols only_after_linking )
    # Canonicalize parameter value
    if (only_after_linking)
        set( only_after_linking "1" )
    else ()
        set( only_after_linking "0" )
    endif()

    # Enabling this for Windows?
    if (CMAKE_SYSTEM_NAME STREQUAL "Windows")

        # First determine if a specific CMake setting shall be used for MSVC and compatible compilers.
        if (POLICY CMP0141)
            cmake_policy( GET CMP0141 use_modern_way )
            if (use_modern_way STREQUAL "NEW")
                set( use_modern_way "TRUE" )
            else()
                set( use_modern_way "FALSE" )
            endif()
        endif()
        # Note: Enabling separate debug symbol files (*.pdb) for MSVC (or Clang-cl) is simple, as
        #       this seems to be the only way to generate (usable) debug symbols. And it is enabled
        #       by default.
        if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR
           (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
            if (ENABLE_EDIT_AND_CONTINUE_DEBUGGING)
                if (use_modern_way)
                    set( CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<AND:$<CXX_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:EditAndContinue>")
                else()
                    add_compile_options( "$<$<AND:$<CXX_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:/ZI>" )
                endif()
            else()
                if (use_modern_way)
                    set( CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<AND:$<CXX_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:ProgramDatabase>")
                else()
                    add_compile_options( "$<$<AND:$<CXX_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:/Zi>" )
                endif()
            endif()
        elseif (CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC" AND
                CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
            # Note: This seems to work out of the box.
        else()
            message( FATAL_ERROR "Enabling separate debug symbols (for C++) is not supported for the chosen OS/compiler combination!" )
        endif()
        if (CMAKE_C_COMPILER_ID STREQUAL "MSVC" OR
           (CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC"))
            if (ENABLE_EDIT_AND_CONTINUE_DEBUGGING)
                if (use_modern_way)
                    set( CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<AND:$<C_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:EditAndContinue>")
                else()
                    add_compile_options( "$<$<AND:$<C_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:/ZI>" )
                endif()
            else()
                if (use_modern_way)
                    set( CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<$<AND:$<C_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:ProgramDatabase>")
                else()
                    add_compile_options( "$<$<AND:$<C_COMPILER_ID:MSVC,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:/Zi>" )
                endif()
            endif()
        elseif (CMAKE_C_SIMULATE_ID STREQUAL "MSVC" AND
                CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_C_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
            # Note: This seems to work out of the box.
        else()
            message( FATAL_ERROR "Enabling separate debug symbols (for C) is not supported for the chosen OS/compiler combination!" )
        endif()

    # Enabling this for Linux (if not cross-compiling)?
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux" AND CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")

        # WARNING: Due to current bugs in tool `dwp` we currently can only split after linking, not earlier!
        set( only_after_linking "1" )

        # Enable splitting debug information into separate `*.dwo` files.
        # Note: This does not work if LTO is enabled.
        if (NOT only_after_linking)
            # Note: Make sure the option is prepended to other "-g.*" options.
            # Sadly, this does not work!
            #add_compile_options( BEFORE $<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-gsplit-dwarf>
            #                            $<$<AND:$<C_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-gsplit-dwarf> )
            # Alternative:
            get_directory_property( prop COMPILE_OPTIONS )
            list( PREPEND prop "$<$<AND:$<CXX_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-gsplit-dwarf>"
                               "$<$<AND:$<C_COMPILER_ID:GNU,Clang>,$<CONFIG:Debug,RelWithDebInfo>>:-gsplit-dwarf>" )
            set_directory_properties( PROPERTIES COMPILE_OPTIONS "${prop}" )
        endif()
        # In order to also create the `*.dwp` files we create a script that needs to be run after linking.
        set( script_content [==[#!/bin/sh
            BINARY_FILE_DIR=$(dirname "$1")
            BINARY_FILE_NAME=$(basename "$1")
            BINARY_FILE_PATH="$1"
            BASE_BUILD_DIR="@CMAKE_BINARY_DIR@"
            NOT_IGNORED="$2"
            if [ "$NOT_IGNORED" -eq "1" ] ; then
                # Compiled with -gsplit-dwarf option?
                if [ "@only_after_linking@" -eq "1" ] ; then
                    @CMAKE_OBJCOPY@ --only-keep-debug "${BINARY_FILE_PATH}" "${BINARY_FILE_PATH}.dwp"
                    @CMAKE_OBJCOPY@ --strip-debug "${BINARY_FILE_PATH}"
                    cd "${BINARY_FILE_DIR}"
                    @CMAKE_OBJCOPY@ --add-gnu-debuglink="${BINARY_FILE_NAME}.dwp" "${BINARY_FILE_NAME}"
                else
                    cd "${BASE_BUILD_DIR}"
                    dwp -e "${BINARY_FILE_PATH}"
                fi
            fi
        ]==])
        # Generate that script in the global scripts directory and set appropriate permissions.
        file( CONFIGURE OUTPUT "${LUCHS_BINARY_DIR}/create_separate_debugsymbols_file.sh"
            CONTENT "${script_content}" @ONLY NEWLINE_STYLE UNIX
        )
        file( CHMOD "${LUCHS_BINARY_DIR}/create_separate_debugsymbols_file.sh"
            PERMISSIONS
                OWNER_READ OWNER_WRITE OWNER_EXECUTE
                GROUP_READ GROUP_WRITE GROUP_EXECUTE
                WORLD_READ
        )

    # Enabling this for Linux (if cross-compiling)?
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
        message( FATAL_ERROR "Enabling separate debug symbols is not supported when cross-compiling for Linux!" )
    # Enabling this for an unsupported OS?
    else()
        message( FATAL_ERROR "Enabling separate debug symbols is not supported for the chosen OS/compiler combination!" )
    endif()
endfunction()


##
# @name create_separate_debugsymbols_file( target )
# @brief Registers a post-build action for the given `target` to create a separate debug-symbols file.
# @param target The target for which a separate debug-symbols file shall be created.
# @note This is an accompanying helper-function for enabling separate debug-symbols.
#
function( create_separate_debugsymbols_file target )
    set( function_name "create_separate_debugsymbols_file" )
    if (NOT TARGET ${target})
        message( FATAL_ERROR "${function_name}: Cannot register post-build action for unknown target '${target}'." )
    endif()
    if (NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
        if (NOT EXISTS "${LUCHS_BINARY_DIR}/create_separate_debugsymbols_file.sh")
            message( FATAL_ERROR "${function_name}: Missing post-build action script. (Did you forget to call 'enable_separate_debugsymbols' before?)" )
        endif()
        # Resolve alias target to its real target.
        get_target_property( real_target ${target} ALIASED_TARGET )
        if (NOT real_target)
            set( real_target "${target}" )
        endif()
        # Add custom command to create a separate debug-symbols file.
        add_custom_command( TARGET ${real_target} POST_BUILD
            COMMAND "${LUCHS_BINARY_DIR}/create_separate_debugsymbols_file.sh"
                    "$<TARGET_FILE:${target}>"
                    "$<CONFIG:Debug,RelWithDebInfo>"
            COMMENT "Creating separate file with debug-symbols for $<TARGET_NAME:${target}>."
        )
    endif()
endfunction()


##
# @name remove_fullpath_to_pdb_from_dll_and_exe()
# @brief Only stores the name to the associated PDB file instead of the full filepath in DLL/EXE.
# @note This only has any effect when compiling with MSVC or a compiler simulating MSVC.
#
function( remove_fullpath_to_pdb_from_dll_and_exe )
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" OR CMAKE_CXX_SIMULATE_ID STREQUAL "MSVC")
        if (NOT CMAKE_GENERATOR MATCHES "Visual Studio.*")
            add_link_options( "$<$<AND:$<OR:$<CXX_COMPILER_ID:MSVC,Clang>,$<STREQUAL:${CMAKE_CXX_SIMULATE_ID},MSVC>>,$<CONFIG:Debug,RelWithDebInfo>>:LINKER:/PDBALTPATH:%_PDB%>" )
            add_link_options( "$<$<AND:$<OR:$<C_COMPILER_ID:MSVC,Clang>,$<STREQUAL:${CMAKE_C_SIMULATE_ID},MSVC>>,$<CONFIG:Debug,RelWithDebInfo>>:LINKER:/PDBALTPATH:%_PDB%>" )
        else()
            message( DEBUG "Visual Studio generators cannot set /PDBALTPATH:<percent>_PDB<percent> linker options properly. (The common, global MSBuild property file needs to be used instead!)" )
        endif()
    endif()
endfunction()
