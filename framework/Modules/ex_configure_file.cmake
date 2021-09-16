##
# @file
# @details Defines a function which mimics `configure_file`'s functionality but evalutates
#          generator-expressions, too. However, the output file will be generated at
#          generation-time (not at configure-time)!
#

include_guard()

##
# @name ex_configure_file( input output [options...] )
# @brief Creates the output file(s) from the input template file and does variable substitution
# @details Generates the output file(s) with the content of the input template file and always
#          substitutes generator-expressions. If option `COPYONLY` is given, no extra variables are
#          substituted. If instead option `@ONLY` is given variables enclosed in `@` characters are
#          substituted (as `configure_file` does it). If neither of these options is present,
#          normal variables as well as those enclosed in `@` charaters will be substituted, too.
# @param input The path to the input file which is the template for the output file(s).
# @param output The path to the output file(s) which will be generated from the input.
# @param options... One of the options of `configure_file`.
# @note Generator-expressions in the output filename will be expanded.
# @note Likewise, generator-expression in the content of the input template file will be expanded,
#       too, unless option `COPYONLY` was given.
# @note This function does not create the output file until the generation phase. The output file
#       will not yet have been written when this function returns, it is written only after
#       processing all `CMakeLists.txt` files (during generation-time)!
#
function( ex_configure_file input output )
    cmake_parse_arguments(
        "_luchs"
        "COPYONLY;ESCAPE_QUOTES;@ONLY;NO_SOURCE_PERMISSIONS;USE_SOURCE_PERMISSIONS"
        "FILE_PERMISSIONS;NEWLINE_STYLE"
        ""
        ${ARGN} )
    # 1. Some sanity checks.
    if ((_luchs_NO_SOURCE_PERMISSIONS AND _luchs_USE_SOURCE_PERMISSIONS) OR
        (DEFINED _luchs_FILE_PERMISSIONS AND (_luchs_NO_SOURCE_PERMISSIONS OR _luchs_USE_SOURCE_PERMISSIONS)))
        message( SEND_ERROR "ex_configure_option: Only one of the three PERMISSIONS options may be given!" )
    endif()
    if (_luchs_USE_SOURCE_PERMISSIONS AND NOT _luchs_COPYONLY)
        message( SEND_ERROR "ex_configure_option: Option USE_SOURCE_PERMISSIONS can only be used together with option COPYONLY!" )
    endif()
    if (_luchs_COPYONLY AND (_luchs_ESCAPE_QUOTES OR _luchs_\@ONLY OR DEFINED _luchs_NEWLINE_STYLE))
        message( SEND_ERROR "ex_configure_option: Option COPYONLY cannot be used together with options \@ONLY, ESCAPE_QUOTES or NEWLINE_STYLE!" )
    endif()
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        foreach( keyword IN LISTS _luchs_KEYWORDS_MISSING_VALUES )
            message( SEND_ERROR "ex_configure_option: Missing value for option ${keyword}!" )
        endforeach()
    endif()
    if (DEFINED _luchs_UNPARSED_ARGUMENTS)
        list( JOIN _luchs_UNPARSED_ARGUMENTS "´, `" _luchs_UNPARSED_ARGUMENTS )
        message( SEND_ERROR "ex_configure_option: Called with unknown arguments! (`${_luchs_UNPARSED_ARGUMENTS}´)" )
    endif()
    # 2. Prepare options.
    if (_luchs_NO_SOURCE_PERMISSIONS)
        set( _luchs_NO_SOURCE_PERMISSIONS "NO_SOURCE_PERMISSIONS" )
    else()
        unset( _luchs_NO_SOURCE_PERMISSIONS )
    endif()
    if (_luchs_USE_SOURCE_PERMISSIONS)
        set( _luchs_USE_SOURCE_PERMISSIONS "USE_SOURCE_PERMISSIONS" )
    else()
        unset( _luchs_USE_SOURCE_PERMISSIONS )
    endif()
    if (DEFINED _luchs_FILE_PERMISSIONS)
        set( _luchs_FILE_PERMISSIONS "FILE_PERMISSIONS;${_luchs_FILE_PERMISSIONS}" )
    endif()
    if (_luchs_ESCAPE_QUOTES)
        set( _luchs_ESCAPE_QUOTES "ESCAPE_QUOTES" )
    else()
        unset( _luchs_ESCAPE_QUOTES )
    endif()
    if (_luchs_\@ONLY)
        set( _luchs_\@ONLY "\@ONLY" )
    else()
        unset( _luchs_\@ONLY )
    endif()
    if (DEFINED _luchs_NEWLINE_STYLE)
        set( _luchs_NEWLINE_STYLE "NEWLINE_STYLE;${_luchs_NEWLINE_STYLE}" )
    endif()
    # 3. Generate the file.
    if (_luchs_COPYONLY)
        file( GENERATE OUTPUT "${output}" INPUT "${input}"
            ${_luchs_USE_SOURCE_PERMISSIONS} ${_luchs_NO_SOURCE_PERMISSIONS} ${_luchs_FILE_PERMISSIONS}
        )
    else()
        file( READ "${input}" input_content )
        string( CONFIGURE "${input_content}" input_content ${_luchs_\@ONLY} ${_luchs_ESCAPE_QUOTES} )
        file( GENERATE OUTPUT "${output}" CONTENT "${input_content}"
            ${_luchs_NO_SOURCE_PERMISSIONS} ${_luchs_FILE_PERMISSIONS}
            ${_luchs_NEWLINE_STYLE}
        )
    endif()
    set_property( SOURCE "${output}" PROPERTY GENERATED 1)
endfunction()
