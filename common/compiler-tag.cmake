##
# @file
# @details Defines three functions for determining and storing the compiler-tag.
#
# @note In general only "store_compiler_tag" and "get_compiler_tag" should ever
#       be called directly by users.
#

include_guard()

# Load helper-functions for determining C++ compiler ID and version.
include( "${CMAKE_CURRENT_LIST_DIR}/determine-compiler.cmake" )


##
# @name determine_compiler_tag()
# @brief Determines the compiler-tag and stores it in a variable `compiler_tag` in local scope.
# @return Variable `compiler_tag` containing the compiler-tag string.
#
function( determine_compiler_tag )
    # Make sure some required variables are (at least locally) set.
    if (NOT DEFINED CMAKE_CXX_COMPILER_ID)
       determine_cxx_compiler_id( CMAKE_CXX_COMPILER_ID )
    endif()
    if (NOT DEFINED CMAKE_CXX_COMPILER_VERSION)
       determine_cxx_compiler_version( CMAKE_CXX_COMPILER_VERSION )
    endif()

    # Determine name-part of compiler-tag.
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        set( compiler_name "clang" )
    elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        set( compiler_name "gcc" )
    else ()
        set( compiler_name "unknown" )
    endif ()
    # Determine version-part of compiler-tag.
    string( REGEX MATCH "^([0-9]+)[.][0-9]+.*"
            compiler_version
            "${CMAKE_CXX_COMPILER_VERSION}" )
    # Store it in parent-scope in variable `compiler_tag`.
    set( compiler_tag "${compiler_name}${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction()


##
# @name get_compiler_tag( out_name )
# @brief Stores the compiler-tag in the given variable.
# @param out_name The name for the variable (in local scope) in which the compiler-tag will be stored.
#
function( get_compiler_tag out_name )
    determine_compiler_tag()
    # Return the compiler-tag via given variable-name.
    set( ${out_name} ${compiler_tag} PARENT_SCOPE )
endfunction()


##
# @name store_compiler_tag( variable_name )
# @brief Stores the compiler-tag in the CMake-cache with the given variable name.
# @param variable_name The name with which the compiler-tag will be stored (as internal variable) in the CMake-cache.
#
function( store_compiler_tag variable_name )
    determine_compiler_tag()
    # Store the compiler-tag permanently.
    set( ${variable_name} ${compiler_tag}
         CACHE INTERNAL
         "The default tag for the currently chosen compiler and compiler-version (used e.g. in directory paths)."
         FORCE)
endfunction()
