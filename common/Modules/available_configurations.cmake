##
# @file
# @details Defines functions which return all available configurations or can duplicate strings
#          with configuration-dependent versions.
#

include_guard()


##
# @name get_available_configurations( out_value )
# @brief Returns the available configurations in the given variable `out_value`.
# @param out_value The name of the variable in which the gathered configurations will be returned
#        to the caller's scope.
#
function( get_available_configurations out_value )
    # Prepare list of available configurations.
    set( configurations )
    if (CMAKE_BUILD_TYPE)
        list( APPEND configurations ${CMAKE_BUILD_TYPE} )
    endif()
    get_cmake_property( is_multi_config_generator GENERATOR_IS_MULTI_CONFIG )
    if (is_multi_config_generator)
        list( APPEND configurations ${CMAKE_CONFIGURATION_TYPES} )
    endif()
    #list( APPEND configurations "" )  # Special "empty" configuration
    list( REMOVE_DUPLICATES configurations )

    # Return configurations
    set( ${out_value} ${configurations} PARENT_SCOPE )
endfunction()


##
# @name get_names_with_configurations( out_value names... )
# @brief Returns duplicates of the given `names` with configurations in the given variable `out_value`.
# @details For each available configuration the given names will be modified with the configuration
#          (in upper-case letters) appended. The entire list of modified names will be returned in
#          variable `out_value`.
#          As an example, `MY_NAME` will result in several variables `MY_NAME_<CONFIG>`.
# @param out_value The name of the variable in which the modified names will be stored
#        in the caller's scope.
# @param names... The names which will be modified and returned.
#
function( get_names_with_configurations out_value ) # name... )
    # Short-circuit if no name given.
    if (ARGC LESS_EQUAL 1)
        return()
    endif()
    # Convenience variable.
    set( names ${ARGN} )

    # Prepare list of available configurations.
    set( configurations )
    get_available_configurations( configurations )

    # Create modified names.
    set( result )
    foreach( name IN LISTS names )
        foreach( config IN LISTS configurations )
            string( TOUPPER "${config}" uppercase_config )
            list( APPEND result "${name}_${uppercase_config}" )
        endforeach()
    endforeach()

    # Return modified names.
    set( ${out_value} ${result} PARENT_SCOPE )
endfunction()

