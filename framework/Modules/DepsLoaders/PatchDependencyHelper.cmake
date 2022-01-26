##
# @file
# @brief Apply the given patch file.
# @details Must be called with the variable `PATCHFILE` that must contain the path to the patch
#          file. The usage is the following:
#          ```
#          cmake -D PATCHFILE=<path-to-patchfile> -P PatchDependencyHelper.cmake
#          ```
#

# Make sure this script was called with a variable `PATCHFILE`.
if (NOT DEFINED PATCHFILE OR "${PATCHFILE}" STREQUAL "")
    message( FATAL_ERROR "Cannot patch because patch-file is missing!" )
endif()


# Check for the existance of the guard that prevents patching a second time.
if (NOT EXISTS ".is_patched")

    # The current time in seconds since the epoch.
    string( TIMESTAMP now "%s" )

    # Apply the given patch, using `git apply` as a universal patch tool.
    execute_process(
        COMMAND git --git-dir=${CMAKE_CURRENT_SOURCE_DIR}/non-existing-dir apply --unsafe-paths -v "${PATCHFILE}"
        COMMAND_ERROR_IS_FATAL ANY
    )

    # Write the guard that prevents patching a second time.
    file( WRITE ".is_patched" "${now}" )
endif()
