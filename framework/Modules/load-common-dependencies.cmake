##
# @file
# @brief Defines functions for loading/listing common dependencies.
#

include_guard()


##
# @name list_loadable_common_dependencies( result_var )
# @brief Returns the list of loadable common dependencies.
# @details Globs the list of available loader files for common dependencies and extracts
#          the names of these dependencies.
# @param result_var The name of the variable in which the result shall be stored.
#
function( list_loadable_common_dependencies result_var )
    # Directory with loader scripts.
    set( depsLoadersDir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/DepsLoaders" )

    # Find dependency loader files and extract the dependencies' names from them.
    file( GLOB available_dependency_loaders
        LIST_DIRECTORIES OFF
        RELATIVE ${depsLoadersDir}
        "${depsLoadersDir}/LoadDependency_*.cmake"
    )
    set( dependencies )
    foreach( filename IN LISTS available_dependency_loaders )
        string( REGEX REPLACE "^LoadDependency_(.+)\.cmake$" "\\1" depname "${filename}" )
        list( APPEND dependencies "${depname}" )
    endforeach()

    # Return the result list.
    set( ${result_var} "${dependencies}" PARENT_SCOPE )
endfunction()


##
# @name load_common_dependency( dependency_name [options...] )
# @brief Loads the requested common dependency.
# @param dependency_name The name of the common dependency that shall be loaded.
# @param options... The optional list of additional options. These can contain `GLOBAL`
#        and `OPTIONAL` as well as other options specific to the dependency.
#
function( load_common_dependency dependency_name )  # options
    # Directory with loader scripts.
    set( depsLoadersDir "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/DepsLoaders" )

    # Try loading the requested dependency.
    cmake_parse_arguments( _luchs
        "GLOBAL;OPTIONAL"  # boolean options
        ""                 # one-value options
        ""                 # multi-value options
        ${ARGN}
    )
    if (NOT _luchs_OPTIONAL)
        set( _luchs_REQUIRED "REQUIRED" )
    else()
        set( _luchs_REQUIRED )  # Set to nothing / unset variable!
    endif()

    if (NOT EXISTS "${depsLoadersDir}/LoadDependency_${dependency_name}.cmake")
        message( SEND_ERROR "Cannot load unknown dependency '${dependency_name}'." )
        return()
    endif()

    # Load dependency (but set required options beforehand).
    set( LOAD_DEPENDENCY_GLOBAL ${_luchs_GLOBAL} )
    set( LOAD_DEPENDENCY_REQUIRED ${_luchs_REQUIRED} )
    set( LOAD_DEPENDENCY_ADDITIONAL_OPTIONS ${_luchs_UNPARSED_ARGUMENTS} )
    include( "${depsLoadersDir}/LoadDependency_${dependency_name}.cmake" )
endfunction()
