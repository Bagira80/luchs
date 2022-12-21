##
# @file
# @details Defines a function which generates a (Doxygen) comment for a (C/C++) source file.
#


##
# @name make_file_comment( outvar [BRIEF summary_str] [DETAILS details_str] [COPYRIGHT_STARTING_YEAR year] )
# @brief Returns via the given output variable a file-comment (with the given information).
# @details The generated file-comment is in Doxygen style and can be put directly into a (C/C++)
#          source file. It always contains a copyright annotation, which attributes copyright to
#          the company `${COMPANY_NAME}` for the current year or, if given, for the range from the
#          given year up until the current year.
# @param[out] outvar The variable via which the resulting string will be returned.
# @param[in] BRIEF summary_str The string containing a brief description of the file.
# @param[in] DETAILS details_str The string containing a detailed description of the file.
# @param[in] COPYRIGHT_STARTING_YEAR year The year that shall be used as date in the copyright
#            notice. If it differs from the current year, it is the starting date of the range up
#            to the current year.
#
function( make_file_comment outvar )
    cmake_parse_arguments(
        "_luchs"
        ""
        "BRIEF;DETAILS;COPYRIGHT_STARTING_YEAR"
        ""
        ${ARGN} )
    if (_luchs_BRIEF)
        string( STRIP "${_luchs_BRIEF}" _luchs_BRIEF )
        string( PREPEND _luchs_BRIEF " * @brief " )
        string( REPLACE "\n" "\n *        " _luchs_BRIEF "${_luchs_BRIEF}" )
        string( APPEND  _luchs_BRIEF "\n" )
    endif()
    if (_luchs_DETAILS)
        string( STRIP "${_luchs_DETAILS}" _luchs_DETAILS )
        string( PREPEND _luchs_DETAILS " * @details " )
        string( REPLACE "\n" "\n *          " _luchs_DETAILS "${_luchs_DETAILS}" )
        string( APPEND  _luchs_DETAILS "\n" )
    endif()
    string( TIMESTAMP copyright_years "%Y" )  # The current year.
    if (_luchs_COPYRIGHT_STARTING_YEAR)
        string( STRIP "${_luchs_COPYRIGHT_STARTING_YEAR}" _luchs_COPYRIGHT_STARTING_YEAR )
        if (NOT _luchs_COPYRIGHT_STARTING_YEAR EQUAL copyright_years)
            string( PREPEND copyright_years "${_luchs_COPYRIGHT_STARTING_YEAR}-" )
        endif()
    endif()
    set( ${outvar} )
    string( APPEND ${outvar}
            "/**\n"
            " * @file\n"
            " * @copyright © ${copyright_years} ${COMPANY_NAME}\n"
            "${_luchs_BRIEF}"
            "${_luchs_DETAILS}"
            " */\n"
    )
    set( ${outvar} "${${outvar}}" PARENT_SCOPE )
endfunction()
