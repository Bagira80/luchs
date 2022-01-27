##
# @file
# @brief Helper functions for fetching a dependency.
#


##
# @name FetchDependency_prepare( name [options...] )
# @brief Makes the preparations for fetching the dependency with the given name.
# @param name The name of the dependency which will be fetched.
# @param options... @parblock
#        Several options for determining the location of the dependency and whether it shall be
#        patched.
#        * LOCAL_PATH must be followed by the path to the directory containing the dependency.
#        * GIT_REPOSITORY must contain the URL to the Git repository containing the dependency.
#        * GIT_TAG determines the Git branch, tag or hash when accessing the Git repository.
#
#        Either LOCAL_PATH or GIT_REPOSITORY must be given. If the latter is given GIT_TAG must be
#        given as well.  
#        Still, all these options can be overriden by environment-variables of the form
#        `LUCHS_DEPENDENCY_<name_in_uppercase>_<option>`.
#        @endparblock
# @note FetchDependency_now() must be called afterwards with the same name argument, in order to
#       successfully fetch the dependency.
#
function(FetchDependency_prepare name )
    set( function_name "FetchDependency_prepare" )
    message( DEBUG "${function_name}: Invoked for dependency '${name}'." )
    string( TOUPPER "${name}" NAME )

    # Parse and verify arguments.
    cmake_parse_arguments(
        "_luchs"
        "PATCH"
        "LOCAL_PATH;GIT_REPOSITORY;GIT_TAG"
        ""
        ${ARGN} )
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        list( JOIN _luchs_KEYWORDS_MISSING_VALUES ", " _luchs_KEYWORDS_MISSING_VALUES )
        message( FATAL_ERROR "${function_name}: Missing values for options. (${_luchs_KEYWORDS_MISSING_VALUES})" )
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        list( JOIN _luchs_UNPARSED_ARGUMENTS "´, `" _luchs_UNPARSED_ARGUMENTS )
        message( FATAL_ERROR "${function_name}: Called with unknown arguments! (`${_luchs_UNPARSED_ARGUMENTS}´)" )
    endif()
    if (DEFINED _luchs_GIT_REPOSITORY AND NOT DEFINED _luchs_GIT_TAG)
        message( FATAL_ERROR "${function_name}: Missing GIT_TAG argument, although GIT_REPOSITORY argument was given." )
    endif()
    if (NOT DEFINED _luchs_LOCAL_PATH AND NOT DEFINED _luchs_GIT_REPOSITORY)
        message( FATAL_ERROR "${function_name}: Either LOCAL_PATH or GIT_REPOSITORY (or both) must be given as arguments." )
    endif()

    # Determine the location of the required dependency sources.
    if (DEFINED ENV{LUCHS_DEPENDENCY_${NAME}_LOCAL_PATH})
        message( DEBUG "${function_name} - ${name}: Using LOCAL_PATH from environment variable." )
        set( _luchs_LOCAL_PATH "URL" "$ENV{LUCHS_DEPENDENCY_${NAME}_LOCAL_PATH}" )
        unset( _luchs_GIT_REPOSITORY )
    elseif (DEFINED ENV{LUCHS_DEPENDENCY_${NAME}_GIT_REPOSITORY})
        message( DEBUG "${function_name} - ${name}: Using GIT_REPOSITORY from environment variable." )
        set( _luchs_GIT_REPOSITORY "GIT_REPOSITORY" "$ENV{LUCHS_DEPENDENCY_${NAME}_GIT_REPOSITORY}" )
        unset( _luchs_LOCAL_PATH )
    elseif (DEFINED _luchs_LOCAL_PATH AND EXISTS "${_luchs_LOCAL_PATH}")
        message( DEBUG "${function_name} - ${name}: Using LOCAL_PATH given as function argument." )
        set( _luchs_LOCAL_PATH "URL" "${_luchs_LOCAL_PATH}" )
        unset( _luchs_GIT_REPOSITORY )
    elseif (DEFINED _luchs_GIT_REPOSITORY)
        message( DEBUG "${function_name} - ${name}: Using GIT_REPOSITORY given as function argument." )
        set( _luchs_GIT_REPOSITORY "GIT_REPOSITORY" "${_luchs_GIT_REPOSITORY}" )
        unset( _luchs_LOCAL_PATH )
    else()
        message( FATAL_ERROR "${function_name}: Directory determined by LOCAL_PATH does not exist and GIT_REPOSITORY is not given." )
    endif()
    if (DEFINED _luchs_GIT_REPOSITORY)
        if (DEFINED ENV{LUCHS_DEPENDENCY_${NAME}_GIT_TAG})
            message( DEBUG "${function_name} - ${name}: Using GIT_TAG from environment variable." )
            set( _luchs_GIT_TAG "GIT_TAG" "$ENV{LUCHS_DEPENDENCY_${NAME}_GIT_TAG}" )
        elseif (DEFINED _luchs_GIT_TAG)
            message( DEBUG "${function_name} - ${name}: Using GIT_TAG given as function argument." )
            set( _luchs_GIT_TAG "GIT_TAG" "${_luchs_GIT_TAG}" )
        else()
            message( FATAL_ERROR "${function_name}: Using GIT_REPOSITORY from environment variable, but missing GIT_TAG value." )
        endif()
    else()
        unset( _luchs_GIT_TAG )
    endif()

    # Prepare patch-command (if patching is requested).
    if (DEFINED _luchs_PATCH)
        set( patchfile_template "${CMAKE_CURRENT_LIST_DIR}/LoadDependency_${name}.patch.in" )
        set( patchfile          "${CMAKE_CURRENT_LIST_DIR}/LoadDependency_${name}.patch" )
        if (EXISTS "${patchfile_template}")
            configure_file( "${patchfile_template}" "${patchfile}" @ONLY NEWLINE_STYLE LF )
            set( _luchs_PATCH "PATCH_COMMAND"
                ${CMAKE_COMMAND} -D "PATCHFILE=${patchfile}" -P "${CMAKE_CURRENT_LIST_DIR}/PatchDependencyHelper.cmake"
            )
        else()
            message( DEBUG "${CMAKE_CURRENT_FUNCTION}(${name}: Patching requested, but no patch-file!" )
            unset( _luchs_PATCH )
        endif()
    endif()

    # Finalize preparation for fetching (and possibly patching) sources.
    include( FetchContent )
    FetchContent_Declare(
        LOAD_DEPENDENCY_${name}
        ${_luchs_LOCAL_PATH} ${_luchs_GIT_REPOSITORY} ${_luchs_GIT_TAG}
        ${_luchs_PATCH}
    )
endfunction()


##
# @name FetchDependency_now( name )
# @brief Fetches the dependency with the given name.
# @param name The name of the dependency which will be fetched.
# @note FetchDependency_prepare() must have been called before with the same name argument, in
#       order for this function to succeed.
#
function( FetchDependency_now name )
    # Fetch source-code and make its CMakeLists.txt available.
    include( FetchContent )
    FetchContent_MakeAvailable( LOAD_DEPENDENCY_${name} )
endfunction()
