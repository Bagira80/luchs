##
# @file
# @details Defines a functions which mimics `source_group`'s functionality but allows more
#          fine-grained grouping.
#


##
# @name add_source_group( [options...] SOURCES sources... )
# @brief Groups the given sources for IDEs, making their (relative) paths single (flat) groups.
# @details Grouping only has any effect for IDEs (like Visual Studio) that support a filtered view
#          for different source and header files.  
#          Without any of the additional options the given `sources` will only be grouped by their
#          directory prefixes. This is especially useful for header files that are required to
#          be included with some directory prefix.  
#          If the `sources` consist of absolute paths one should use the `STRIP_PREFIXES` option
#          to strip the unneeded parts (e.g. strip `${CMAKE_CURRENT_SOURCE_DIR}`). The remaining
#          path will then become part of the group.
# @param SOURCES sources... The individual sources that will be grouped for IDEs.
# @param options... Some options that allow more fine-grained grouping of the sources:
#       - INCLUDE_FILTER <regex>  
#         Matches the sources against the given regex and only further processes the matching
#         sources.
#       - EXCLUDE_FILTER <regex>  
#         Matches the sources against the given regex and only further processes the non-matching
#         sources.
#       - GROUP <string>  
#         The group into which to put the sources. (Their directory prefixes will still make up
#         some subgroups.)
#       - FLAT_GROUP  
#         Results in a directory prefix of a source file becoming a single (flat) group, instead of
#         multiple subgroups split at the directory separator.
#       - STRIP_PREFIXES  
#         The prefixes that will be split of the sources, so that they do not become part of the
#         directory prefixes.
# @note Only one of *INCLUDE_FILTER* and *EXCLUDE_FILTER* may be used.
#
function( add_source_group )
    cmake_parse_arguments(
         "_luchs"
         "FLAT_GROUP"
         "INCLUDE_FILTER;EXCLUDE_FILTER;GROUP"
         "STRIP_PREFIXES;SOURCES"
         ${ARGN} )
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        # Note: Missing values for SOURCES is not an error!
        if ("SOURCES" IN_LIST _luchs_KEYWORDS_MISSING_VALUES)
            message( DEBUG "WARNING -- ${CMAKE_CURRENT_FUNCTION}: Missing sources!" )
            list( REMOVE_ITEM _luchs_KEYWORDS_MISSING_VALUES "SOURCES" )
        endif()
        if (NOT "${_luchs_KEYWORDS_MISSING_VALUES}" STREQUAL "")
            list( JOIN _luchs_KEYWORDS_MISSING_VALUES "`, `" _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Missing values for keyword(s) (`${_luchs_KEYWORDS_MISSING_VALUES}`)!" )
        endif()
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        list( JOIN _luchs_UNPARSED_ARGUMENTS "`, `" _luchs_UNPARSED_ARGUMENTS )
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Received unknown option(s) (`${_luchs_UNPARSED_ARGUMENTS}`)!" )
    endif()
    if ((DEFINED _luchs_INCLUDE_FILTER) AND (DEFINED _luchs_EXCLUDE_FILTER))
        message( SEND_ERROR "${CMAKE_CURRENT_FUNCTION}: Only one of INCLUDE_FILTER and EXCLUDE_FILTER may be used!" )
    endif()
    if (DEFINED _luchs_GROUP)
        set( _luchs_GROUP "${_luchs_GROUP}/" )  # Add slash.
    endif()
    if (DEFINED _luchs_STRIP_PREFIXES)
        # Sort by descending length.
        set( prefixes )
        foreach( prefix IN LISTS _luchs_STRIP_PREFIXES )
            string( LENGTH "${prefix}" length )
            list( APPEND prefixes "${length}##${prefix}" )  # Store prefix with its length prepended!
        endforeach()
        list( SORT prefixes COMPARE NATURAL ORDER DESCENDING )
        list( TRANSFORM prefixes REPLACE "^[0-9]+##" "" )  # Remove prepended length again from all prefixes.
        set( _luchs_STRIP_PREFIXES "${prefixes}" )
        unset( prefixes )
    endif()
    set( sources_list )
    if (DEFINED _luchs_SOURCES)
        set( sources_list "${_luchs_SOURCES}" )
    endif()

    # Filter the list of sources to only contain sources that should be put into a source-group.
    if (DEFINED _luchs_INCLUDE_FILTER)
        list( FILTER sources_list INCLUDE REGEX "${_luchs_INCLUDE_FILTER}" )
    elseif (DEFINED _luchs_EXCLUDE_FILTER)
        list( FILTER sources_list EXCLUDE REGEX "${_luchs_EXCLUDE_FILTER}" )
    endif()

    # No sources to process?
    if ("${sources_list}" STREQUAL "")
        return()
    endif()

    # Create list of prefixes from list of sources.
    set( prefixes_list "${sources_list}" )
    list( TRANSFORM prefixes_list REPLACE "/[^/]*$" "" )  # Strip filenames.
    list( REMOVE_DUPLICATES prefixes_list )
    list( SORT prefixes_list COMPARE NATURAL ORDER DESCENDING )

    set( BIG_SOLIDUS "⧸" )  # Alternative slash character, represented by "BIG SOLIDUS" (U+29F8).

    foreach( prefix IN LISTS prefixes_list )
        # Extract sources matching the prefix.
        set( filtered_sources "${sources_list}" )
        string( REGEX REPLACE "(.)" "[\\1]" prefix_regex "${prefix}" )  # Regex matching prefix exactly!
        list( FILTER filtered_sources INCLUDE REGEX "^${prefix_regex}.*" )
        # Remove extracted sources from original list of sources.
        list( REMOVE_ITEM sources_list ${filtered_sources} )

        # Strip given STRIP_PREFIXES from current prefix.
        foreach( strip_prefix IN LISTS _luchs_STRIP_PREFIXES )
            string( REGEX REPLACE "(.)" "[\\1]" strip_prefix_regex "${strip_prefix}" )  # Regex matching strip_prefix exactly!
            if (prefix MATCHES "^${strip_prefix_regex}(.*)")
                set( prefix "${CMAKE_MATCH_1}" )
                break()
            endif()
        endforeach()

        # Replace slash by "BIG SOLIDUS" in prefix (so that the prefix will not be broken apart at slashes)?
        if (_luchs_FLAT_GROUP)
            string( REPLACE "/" "${BIG_SOLIDUS}" prefix "${prefix}" )
        endif()

        # Add filtered sources to group with additional prefix.
        source_group( "${_luchs_GROUP}${prefix}" FILES ${filtered_sources} )
    endforeach()
endfunction()
