##
# @file
# @details Defines helper functions for printing properties of targets etc.
#

include_guard()


# ----------------------------------------------------------------------
# Get all properties that CMake supports (and for which help-entries exist).
# ----------------------------------------------------------------------
if (NOT DEFINED CMAKE_PROPERTY_LIST)

    # Retrieve all properties for which a help-entry exists.
    execute_process(
        COMMAND ${CMAKE_COMMAND} --help-property-list
        OUTPUT_VARIABLE CMAKE_PROPERTY_LIST
    )
    # Convert command output into a CMake-list.
    string( REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}" )
    string( REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}" )
    list( REMOVE_DUPLICATES CMAKE_PROPERTY_LIST )

    # Set cache-variable with supported properties.
    set( CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}" CACHE STRING
         "The list of properties supported by (normal) targets (and for which a help-entry exists)." )
    unset (CMAKE_PROPERTY_LIST)

endif()
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# Get all properties that (normal) CMake targets supports.
# ----------------------------------------------------------------------
if (NOT DEFINED CMAKE_TARGET_PROPERTY_LIST)

    # Create a list of all properties additionally prefixed with "INTERFACE_".
    set( CMAKE_TARGET_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}" )
    foreach (prop ${CMAKE_PROPERTY_LIST})
        if (NOT "${prop}" MATCHES "^INTERFACE_")
            list( APPEND CMAKE_TARGET_PROPERTY_LIST "INTERFACE_${prop}" )
        endif ()
    endforeach ()
#[[
    # Check which of the properties are not defined for (normal) targets.
    # NOTE: This is entered if recursively called!
    if (DEFINED CURRENTLY_TESTING_FOR_TARGET_PROPERTIES)
        add_library( dummy SHARED dummy.cpp )
        foreach (prop ${CMAKE_TARGET_PROPERTY_LIST})
            string( REPLACE "<CONFIG>" "DEBUG" prop ${prop} )
            string( REPLACE "<LANG>" "CXX" prop ${prop} )
            # NOTE: If no documentation exists, the property is not defined!
            get_property( propval TARGET dummy PROPERTY ${prop} BRIEF_DOCS )
            if (NOT propval)
                message( WARNING "${prop}" )  # Print invalid property to error-stream.
            endif()
        endforeach()
        return()
    endif()
    # Retrieve the warning-messages about properties which are undefined for targets.
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E make_directory tmp_properties_test
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_FILE} tmp_properties_test/CMakeLists.txt
        COMMAND ${CMAKE_COMMAND} -E touch tmp_properties_test/dummy.cpp
        COMMAND ${CMAKE_COMMAND} -E chdir tmp_properties_test ${CMAKE_COMMAND} -DCURRENTLY_TESTING_FOR_TARGET_PROPERTIES:BOOL=TRUE .
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        OUTPUT_QUIET
        ERROR_VARIABLE CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST
    )
    # Remove temporary build-directory again.
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E remove_directory tmp_properties_test
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        OUTPUT_QUIET
        ERROR_QUIET
    )
    # Convert command (error-)output into a CMake-list.
    string( REGEX MATCHALL ":[ \t\n]+[^ \t\n]+" CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST "${CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST}" )
    string( REGEX MATCHALL "[^: \t\n]+" CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST "${CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST}" )
    string( REGEX REPLACE ";+" ";" CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST "${CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST}" )

    # Create a list of all properties that (normal) CMake targets support.
    foreach (prop ${CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST})
        list( REMOVE_ITEM CMAKE_TARGET_PROPERTY_LIST "${prop}" )
        string( REPLACE "DEBUG" "<CONFIG>" prop ${prop} )
        string( REPLACE "CXX" "<LANG>" prop ${prop} )
        list( REMOVE_ITEM CMAKE_TARGET_PROPERTY_LIST "${prop}" )
    endforeach()
]]
    list( REMOVE_DUPLICATES CMAKE_TARGET_PROPERTY_LIST )
    # Set cache-variable with supported properties.
    set( CMAKE_TARGET_PROPERTY_LIST "${CMAKE_TARGET_PROPERTY_LIST}" CACHE STRING
         "The list of properties supported by (normal) CMake targets." )
    unset( CMAKE_TARGET_PROPERTY_LIST )
    unset( CMAKE_NOT_DEFINED_TARGET_PROPERTY_LIST )

endif()
# ----------------------------------------------------------------------


# ----------------------------------------------------------------------
# Get all properties that CMake INTERFACE targets support.
# ----------------------------------------------------------------------
if (NOT DEFINED CMAKE_INTERFACE_TARGET_PROPERTY_LIST)

    # Retrieve all currently supported languages.
    get_property( CURRENTLY_ENABLED_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES )

    # Check which of the properties are not defined for (INTERFACE) targets.
    # NOTE: This is entered if recursively called!
    if (DEFINED CURRENTLY_TESTING_FOR_INTERFACE_TARGET_PROPERTIES)
        add_library( dummy INTERFACE )
        foreach (prop ${CMAKE_TARGET_PROPERTY_LIST})
            string( REPLACE "<CONFIG>" "DEBUG" prop ${prop} )
            if ("${prop}" MATCHES ".*<LANG>.*")
                foreach (lang ${CURRENTLY_ENABLED_LANGUAGES})
                    string( REPLACE "<LANG>" "${lang}" lang_prop ${prop} )
                    get_property( propval TARGET dummy PROPERTY ${lang_prop} SET )
                endforeach()
            else()
                get_property( propval TARGET dummy PROPERTY ${prop} SET )
            endif()
        endforeach()
        return()
    endif()
    # Retrieve the warning-messages about properties that are not supported for INTERFACE targets.
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E make_directory tmp_properties_test
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_LIST_FILE} tmp_properties_test/CMakeLists.txt
        COMMAND ${CMAKE_COMMAND} -E chdir tmp_properties_test ${CMAKE_COMMAND} -D CURRENTLY_TESTING_FOR_INTERFACE_TARGET_PROPERTIES:BOOL=TRUE .
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        OUTPUT_QUIET
        ERROR_VARIABLE CMAKE_NOT_SUPPORTED_INTERFACE_TARGET_PROPERTY_LIST
    )
    # Remove temporary build-directory again.
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E remove_directory tmp_properties_test
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        OUTPUT_QUIET
        ERROR_QUIET
    )
    # Convert command (error-)output into a CMake-list.
    string( REGEX MATCHALL "[\"][^\"]+[\"]" CMAKE_NOT_SUPPORTED_INTERFACE_TARGET_PROPERTY_LIST "${CMAKE_NOT_SUPPORTED_INTERFACE_TARGET_PROPERTY_LIST}" )
    string( REGEX REPLACE "[\"]([^\"]+)[\"]" "\\1" CMAKE_NOT_SUPPORTED_INTERFACE_TARGET_PROPERTY_LIST "${CMAKE_NOT_SUPPORTED_INTERFACE_TARGET_PROPERTY_LIST}" )
    # Create a list of all properties that CMake INTERFACE targets support.
    set( CMAKE_INTERFACE_TARGET_PROPERTY_LIST "${CMAKE_TARGET_PROPERTY_LIST}" )
    foreach (prop ${CMAKE_NOT_SUPPORTED_INTERFACE_TARGET_PROPERTY_LIST})
        list( REMOVE_ITEM CMAKE_INTERFACE_TARGET_PROPERTY_LIST "${prop}" )
        string( REPLACE "DEBUG" "<CONFIG>" prop ${prop} )
        string( REPLACE "CXX" "<LANG>" prop ${prop} )
        list( REMOVE_ITEM CMAKE_INTERFACE_TARGET_PROPERTY_LIST "${prop}" )
    endforeach()
    string( REGEX REPLACE ";+" ";" CMAKE_INTERFACE_TARGET_PROPERTY_LIST "${CMAKE_INTERFACE_TARGET_PROPERTY_LIST}" )
    list( REMOVE_DUPLICATES CMAKE_INTERFACE_TARGET_PROPERTY_LIST )

    # Set cache-variable with supported properties.
    set( CMAKE_INTERFACE_TARGET_PROPERTY_LIST "${CMAKE_INTERFACE_TARGET_PROPERTY_LIST}" CACHE STRING
         "The list of properties supported by INTERFACE CMake targets." )
    unset( CMAKE_INTERFACE_TARGET_PROPERTY_LIST )
    unset( CMAKE_NOT_SUPPORTED_INTERFACE_TARGET_PROPERTY_LIST )
    unset( CURRENTLY_ENABLED_LANGUAGES )

endif()
# ----------------------------------------------------------------------


##
# @name print_all_properties()
# @brief Prints the property-list supported by CMake.
#
function (print_all_properties)
    message ("CMAKE_PROPERTY_LIST = ${CMAKE_PROPERTY_LIST}")
endfunction ()


##
# @name print_all_target_properties()
# @brief Prints the property-list supported by (normal) CMake targets.
#
function (print_all_target_properties)
    message ("CMAKE_TARGET_PROPERTY_LIST = ${CMAKE_TARGET_PROPERTY_LIST}")
endfunction ()


##
# @name print_all_interface_target_properties()
# @brief Prints the property-list supported by INTERFACE CMake targets.
#
function (print_all_interface_target_properties)
    message ("CMAKE_INTERFACE_TARGET_PROPERTY_LIST = ${CMAKE_INTERFACE_TARGET_PROPERTY_LIST}")
endfunction ()


##
# @name print_target_property( target prop )
# @brief Prints the requested property of the given target.
# @param target The target whose requested property will be printed.
# @param prop The requested property of the target which will be printed.
#
function (print_target_property target prop)
    if (NOT TARGET ${target})
        message( SEND_ERROR "There is no target named '${target}'." )
        return()
    endif()

    #get_property( propval TARGET dummy PROPERTY ${prop} BRIEF_DOCS )
    #if (NOT propval)
    #    message( SEND_ERROR "There is not target property named '${prop}' defined." )
    #    return()
    #endif()

    get_property( propval TARGET ${target} PROPERTY ${prop} SET )
    if (propval)
        get_target_property( propval ${target} ${prop} )
        message( STATUS "${target} ${prop} = ${propval}" )
    endif()
endfunction()


##
# @name print_target_properties( target )
# @brief Prints the properties supported by the given target.
# @param target The target whose properties will be printed.
#
function (print_target_properties target)
    if (NOT TARGET ${target})
        message( SEND_ERROR "There is no target named '${target}'." )
        return()
    endif()

    # Determine the correct properties-list which shall be printed.
    get_property( propval TARGET ${target} PROPERTY "TYPE" SET )
    if (propval)
        get_property( propval TARGET ${target} PROPERTY "TYPE" )
        if ("${propval}" STREQUAL "INTERFACE_LIBRARY")
            set( SUPPORTED_PROPERTIES "${CMAKE_INTERFACE_TARGET_PROPERTY_LIST}" )
        else ()
            set( SUPPORTED_PROPERTIES "${CMAKE_TARGET_PROPERTY_LIST}" )
        endif()
    else()
        message( FATAL_ERROR "A target should have a TYPE property set!" )
    endif()

    # Determine the build-type.
    string( TOUPPER "${CMAKE_BUILD_TYPE}" PROP_BUILD_TYPE )
    if (NOT PROP_BUILD_TYPE)
        set( PROP_BUILD_TYPE "DEBUG" )
    endif()

    # The list of enabled languages.
    get_property( enabled_languages GLOBAL PROPERTY ENABLED_LANGUAGES )

    # Print each supported property (if set).
    foreach (prop ${SUPPORTED_PROPERTIES})
        # Skip reading the LOCATION properties, as it is no longer supported.
        # See: https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
        if (prop STREQUAL "LOCATION" OR prop MATCHES "^LOCATION_" OR prop MATCHES "_LOCATION$")
            continue()
        endif()

        # Use current build-type.
        string( REPLACE "<CONFIG>" "${PROP_BUILD_TYPE}" prop ${prop} )
        # Print target-property for all enabled lanugages.
        if ("${prop}" MATCHES ".*<LANG>.*")
            foreach (lang ${enabled_languages})
                string( REPLACE "<LANG>" "${lang}" lang_prop ${prop} )
                print_target_property( ${target} ${lang_prop} )
            endforeach()
        else()
            print_target_property( ${target} ${prop} )
        endif()
    endforeach()
endfunction()

