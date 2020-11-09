##
# @file
# @details Defines a function which sets properties on or retrieves properties from targets which
#          are associated with specific components.
#

include_guard()

include( ${CMAKE_CURRENT_LIST_DIR}/available_configurations.cmake )

##
# @name set_associated_target_properties( <options> PROPERTIES prop_value_pair [...] COMPONENTS [components...] )
# @brief Sets the given property/value pairs on the targets associated with the given components.
# @details The given property/value pairs will be set on targets which are associated with any of
#          the given components. If option `FOR_ALL_CONFIGURATIONS` is used then, additionally,
#          component-dependent versions of each property are set, too. If option `APPEND` is used
#          existing properites will not be replaced but instead the new value will be appended
#          (as CMake list).
#          In order to find the targets associated with a component the following global property
#          must already be set and its value must be the list of associated targets:
#          `TARGETS_ASSOCIATED_WITH_COMPONENT_<component>`
# @param <options> Options `FOR_ALL_CONFIGURATIONS` and `APPEND` that are used as described in the
#         detailed desription of this function.
# @param prop_value_pair... Pairs of property name and value, which shall be set on the targets
#        associated with the components.
# @param components... The components on whose associated targets the properties will be set.
#
function( set_associated_target_properties )
    cmake_parse_arguments(
        "_"
        "APPEND;FOR_ALL_CONFIGURATIONS"
        ""
        "COMPONENTS;PROPERTIES"
        ${ARGN}
    )

    # Check and verify option: PROPERTIES
    if ("PROPERTIES" IN_LIST __KEYWORDS_MISSING_VALUES)
        message( SEND_ERROR "Mandatory argument PROPERTIES is missing its values!" )
        return()
    elseif (NOT DEFINED __PROPERTIES)
        message( SEND_ERROR "Mandatory argument PROPERTIES is missing!" )
        return()
    endif()
    list( LENGTH __PROPERTIES PROPERTIES_length )
    math( EXPR result "${PROPERTIES_length} % 2" )
    if (result OR PROPERTIES_length EQUAL 0)
        message( SEND_ERROR "Mandatory argument PROPERTIES got invalid number of values! "
                            "(Its values must consist of pairs of property name and value.)" )
        return()
    endif()

    # Check for unparsed arguments.
    if (DEFINED __UNPARSED_ARGUMENTS)
        message( SEND_ERROR "Received unknown arguments. (${__UNPARSED_ARGUMENTS})" )
        return()
    endif()

    # Check and verify option: COMPONENTS
    if (NOT DEFINED __COMPONENTS)
        if ("COMPONENTS" IN_LIST __KEYWORDS_MISSING_VALUES)
            return()  # Short-circuit because no or empty components given.
        else()
            message( SEND_ERROR "Required argument COMPONENTS is missing!" )
            return()
        endif()
    endif()


    # Retrieve list of targets for all components.
    # Note: A variable TARGETS_ASSOCIATED_WITH_COMPONENT_<component> must exist for a
    #       component <component> which should be the list of targets.
    set( targets )
    foreach( component IN LISTS __COMPONENTS )
        get_property( targets_of_component GLOBAL PROPERTY TARGETS_ASSOCIATED_WITH_COMPONENT_${component} )
        foreach( target IN LISTS targets_of_component )
            get_target_property( aliased_target ${target} ALIASED_TARGET )
            if (aliased_target)
                list( APPEND targets ${aliased_target} )
            else()
                list( APPEND targets ${target} )
            endif()
        endforeach()
    endforeach()
    if (NOT DEFINED targets)
        return()  # Short-circuit because no targets encountered.
    endif()
    list( REMOVE_DUPLICATES targets )

    # Prepare list of available configurations (if so desired).
    if (__FOR_ALL_CONFIGURATIONS)
        get_available_configurations( configurations )
    endif()

    # For each property/value pair:
    math( EXPR last_index "${PROPERTIES_length} - 1" )
    foreach( index RANGE 0 ${last_index} 2)
        # Retrieve current property/value pair.
        list( GET __PROPERTIES "${index}" current_property )
        math( EXPR next_index "${index} + 1" )
        list( GET __PROPERTIES ${next_index} current_property_value )

        set( properties )
        # Add component-dependent property to list of properties?
        if (__FOR_ALL_CONFIGURATIONS)
            foreach( config IN LISTS configurations )
                string( TOUPPER "${config}" uppercase_config )
                list( APPEND properties "${current_property}_${uppercase_config}" )
            endforeach()
        endif()
        # Add component-less property to list of properties.
        list( APPEND properties "${current_property}" )

        # Mark these properties as exportable by the targets.
        set_property( TARGET ${targets} APPEND PROPERTY EXPORT_PROPERTIES "${properties}" )

        # Set property/value pairs on targets.
        # ... Append to existing properties?
        if (__APPEND)
            foreach( prop IN LISTS properties )
                set_property( TARGET ${targets} APPEND PROPERTY ${prop} ${current_property_value} )
            endforeach()
        # ... Replace existing properties?
        else()
            # Combine properties with value.
            list( JOIN properties ";${current_property_value};" properties_with_values )
            list( APPEND properties_with_values "${current_property_value}" )
            # Set properties and values.
            set_target_properties( ${targets} PROPERTIES ${properties_with_values} )
        endif()
    endforeach()
endfunction()

##
# @name get_linked_target_properties( out_var <options> PROPERTIES properties [...] COMPONENTS [components...] )
# @brief Returns the values of the given properties from the targets associated with the given components.
# @details The values of the given properties will be retrieved from the targets which are
#          associated with any of the given components. If option `FOR_ALL_CONFIGURATIONS` is used
#          then, additionally, component-dependent versions of each property are checked, too. The
#          retrieved values will be returned through the variable `out_var` in the caller's scope.
#          If option `APPEND` is used the original value of that variable will not be replaced but
#          instead the new value will be appended (as CMake list).
#          In order to find the targets associated with a component the following global property
#          must already be set and its value must be the list of associated targets:
#          `TARGETS_ASSOCIATED_WITH_COMPONENT_<component>`
# @param out_var The variable in the caller's scope through which the retrieved values will be
#        returned.
# @param <options> Options `FOR_ALL_CONFIGURATIONS` and `APPEND` that are used as described in the
#         detailed desription of this function.
# @param properties... Properties whose values shall be retrieved from the targets associated with
#        the components.
# @param components... The components from whose associated targets the properties will be
#        retrieved.
#
function( get_linked_target_properties out_var)
    cmake_parse_arguments(
        "_"
        "APPEND;FOR_ALL_CONFIGURATIONS"
        ""
        "COMPONENTS;PROPERTIES"
        ${ARGN}
    )

    # Check and verify option: PROPERTIES
    if ("PROPERTIES" IN_LIST __KEYWORDS_MISSING_VALUES)
        message( SEND_ERROR "Mandatory argument PROPERTIES is missing its values!" )
        return()
    elseif (NOT DEFINED __PROPERTIES)
        message( SEND_ERROR "Mandatory argument PROPERTIES is missing!" )
        return()
    endif()

    # Check for unparsed arguments.
    if (DEFINED __UNPARSED_ARGUMENTS)
        message( SEND_ERROR "Received unknown arguments. (${__UNPARSED_ARGUMENTS})" )
        return()
    endif()

    # Check and verify option: COMPONENTS
    if (NOT DEFINED __COMPONENTS)
        if ("COMPONENTS" IN_LIST __KEYWORDS_MISSING_VALUES)
            return()  # Short-circuit because no or empty components given.
        else()
            message( SEND_ERROR "Required argument COMPONENTS is missing!" )
            return()
        endif()
    endif()


    # Retrieve list of targets for all components.
    # Note: A variable TARGETS_ASSOCIATED_WITH_COMPONENT_<component> must exist for a
    #       component <component> which should be the list of targets.
    set( targets )
    foreach( component IN LISTS __COMPONENTS )
        get_property( targets_of_component GLOBAL PROPERTY TARGETS_ASSOCIATED_WITH_COMPONENT_${component} )
        list( APPEND targets ${targets_of_component} )
    endforeach()
    if (NOT DEFINED targets)
        return()  # Short-circuit because no targets encountered.
    endif()
    list( REMOVE_DUPLICATES targets )

    set( other_targets )
    foreach( target IN LISTS targets )
        get_target_property( link_libs ${target} LINK_LIBRARIES )
        get_target_property( interface_link_libs ${target} INTERFACE_LINK_LIBRARIES )
        foreach( link_target IN LISTS link_libs interface_link_libs )
            if (NOT link_target)
                continue()
            endif()
            if ( link_target MATCHES "^[$][<]LINK_ONLY:([^>]+)[>]$" )
                list( APPEND other_targets ${CMAKE_MATCH_1} )
            elseif ( link_target MATCHES "^[$][<]BUILD_INTERFACE:([^>]+)[>]$" )
                list( APPEND other_targets ${CMAKE_MATCH_1} )
            elseif ( link_target MATCHES "^[$][<]INSTALL_INTERFACE:([^>]+)[>]$" )
                list( APPEND other_targets ${CMAKE_MATCH_1} )
            else()
                list( APPEND other_targets ${link_target} )
            endif()
        endforeach()
    endforeach()
    list( REMOVE_DUPLICATES other_targets )

    # Prepare list of available configurations (if so desired).
    if (__FOR_ALL_CONFIGURATIONS)
        get_available_configurations( configurations )
    endif()

    # For each property:
    set( retrieved_values )
    foreach( current_property IN LISTS __PROPERTIES )
        set( properties )
        # Add component-dependent property to list of properties?
        if (__FOR_ALL_CONFIGURATIONS)
            foreach( config IN LISTS configurations )
                string( TOUPPER "${config}" uppercase_config )
                list( APPEND properties "${current_property}_${uppercase_config}" )
            endforeach()
        endif()
        # Add component-less property to list of properties.
        list( APPEND properties "${current_property}" )

        # Get properties' values from targets.
        foreach( other_target IN LISTS other_targets )
            if (NOT TARGET ${other_target})
                if ("${other_target}" MATCHES "^[$][<][^>]+[>]")
                    message( WARNING "Not a (valid) target (because I cannot evaluate generator-expressions): ${other_target}" )
                elseif (${other_target} MATCHES "^[-].+")
                    message( DEBUG "Not a target, but possibly an option: ${other_target}" )
                elseif (${other_target} MATCHES "[/][^/]+")
                    message( DEBUG "Not a target, but possibly a library to link: ${other_target}" )
                else()
                    message( WARNING "Not a (known) target: ${other_target}" )
                endif()
                continue()
            endif()
            foreach( prop IN LISTS properties )
                get_target_property( value ${other_target} ${prop} )
                list( APPEND retrieved_values "${value}" )
            endforeach()
        endforeach()
    endforeach()
    list( REMOVE_DUPLICATES retrieved_values )
    list( FILTER retrieved_values EXCLUDE REGEX ".+-NOTFOUND" )

    # Return retrieved values.
    if (__APPEND)
        list( PREPEND retrieved_values ${${out_var}} )
    endif()
    set( ${out_var} "${retrieved_values}" PARENT_SCOPE )
endfunction()

