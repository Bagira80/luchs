##
# @file
# @details Defines a functions which is able to copy properties from several targets to another
#          target.
#

include_guard()

##
# @name copy_properties( target [options...] PROPERTIES property [property...] FROM source [source] )
# @brief Copies the mentioned properties from the source targets to the target
# @details Copies the mentioned properties from the source targets to the target. Existing
#          properties of target will not be replaced, instead the new properties are appended.
# @param target The target to which the properties will be copied.
# @param property The property that will be copied.
# @param source The source target from which the properties will be copied.
# @param options... Either REMOVE_DUPLICATES or SKIP_LINK_ONLY. The former results in removing
#        duplicates from the mentioned properties of target. While the latter skips copying
#        property values which are enclosed in $<LINK_ONLY:...> generator expressions. (This
#        mainly affects property `INTERFACE_LINK_LIBRARIES`.)
#
function( copy_properties target )
    cmake_parse_arguments(
         "_"
         "REMOVE_DUPLICATES;SKIP_LINK_ONLY"
         ""
         "PROPERTIES;FROM"
         ${ARGN} )
    if (${__UNPARSED_ARGUMENTS})
        message( SEND_ERROR "copy_properties called with unknown arguments!" )
    endif()
    if (NOT (TARGET ${target}))
        message( FATAL_ERROR "copy_properties cannot copy properties to non-existing target `${target}`!" )
    endif()
    foreach( source IN LISTS __FROM )
        if (NOT TARGET ${source})
            message( FATAL_ERROR "copy_properties cannot copy properties from non-existing target `${target}`!" )
        endif()
    endforeach()

    # Copy properties.
    foreach( property IN LISTS __PROPERTIES )
        foreach( source IN LISTS __FROM )
            get_target_property( prop ${source} ${property} )
            if (prop)
                # Skip `$<LINK_ONLY:...>` properties?
                if (__SKIP_LINK_ONLY)
                    string( REGEX REPLACE "(^|[;])[$][<]LINK_ONLY:[^;]+" "\\1" prop "${prop}" )
                endif()
                set_property( TARGET ${target} APPEND PROPERTY ${property} ${prop} )
            endif()
        endforeach()
        # Remove duplicates?
        if (__REMOVE_DUPLICATES)
            get_target_property( prop ${target} ${property} )
            if (prop)
                list( REMOVE_DUPLICATES prop )
                set_property( TARGET ${target} PROPERTY ${property} ${prop} )
            endif()
        endif()
    endforeach()
endfunction()
