##
# @file
# @details Defines a function which is able to copy properties from several targets to a target.
#

include_guard()

##
# @name copy_target_properties( target [options...] PROPERTIES property [property...] FROM source [source...] )
# @brief Copies the given properties from the source targets to the destination target
# @details Copies the given properties from the source targets to the destination target. Existing
#          properties of the destination target will not be replaced, instead the new properties
#          will be appended.
# @param target The destination target to which the properties will be copied.
# @param property The property that will be copied.
# @param source The source target from which the properties will be copied.
# @param options... Either `REMOVE_DUPLICATES` or `SKIP_LINK_ONLY`. The former results in removing
#        duplicates from the mentioned properties of the destination target, while the latter skips
#        copying property values which are enclosed in `$<LINK_ONLY:...>` generator expressions.
#        (This mainly affects property `INTERFACE_LINK_LIBRARIES`.)
#
function( copy_target_properties target )
    cmake_parse_arguments(
        "_luchs"
        "REMOVE_DUPLICATES;SKIP_LINK_ONLY"
        ""
        "PROPERTIES;FROM"
        ${ARGN} )
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION} called with unknown arguments!" )
    endif()
    if (NOT TARGET "${target}")
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION} cannot copy properties to non-existing target `${target}`!" )
    endif()
    list( FILTER _luchs_FROM EXCLUDE REGEX "^$" )  # Remove empty and duplicate entries
    list( REMOVE_DUPLICATES _luchs_FROM )          #   from list of source targets.
    foreach( source IN LISTS _luchs_FROM )
        if (NOT TARGET "${source}")
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION} cannot copy properties from non-existing target `${target}`!" )
        endif()
    endforeach()
    # Short-circuit?
    list( LENGTH _luchs_FROM size)
    if (size EQUAL 0)
        message( DEBUG "${CMAKE_CURRENT_FUNCTION} skips copying to `${target}` because no target to copy from." )
        return()
    endif()

    # Copy properties.
    foreach( property IN LISTS _luchs_PROPERTIES )
        foreach( source IN LISTS _luchs_FROM )
            get_target_property( prop ${source} ${property} )
            if (prop)
                # Skip `$<LINK_ONLY:...>` properties?
                if (_luchs_SKIP_LINK_ONLY)
                    string( REGEX REPLACE "(^|[;])[$][<]LINK_ONLY:[^;]+" "\\1" prop "${prop}" )
                    list( FILTER prop EXCLUDE REGEX "^$" )
                endif()
                if (NOT "${prop}" STREQUAL "")
                    set_property( TARGET ${target} APPEND PROPERTY ${property} ${prop} )
                endif()
            endif()
        endforeach()
        # Remove duplicates?
        if (_luchs_REMOVE_DUPLICATES)
            get_target_property( prop ${target} ${property} )
            if (prop)
                list( REMOVE_DUPLICATES prop )
                set_property( TARGET ${target} PROPERTY ${property} ${prop} )
            endif()
        endif()
    endforeach()
endfunction()
