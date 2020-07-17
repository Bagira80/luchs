##
# @file
# @details Defines a functions which mimics `configure_file`'s functionality but evalutates
#          generator-expressions, too. However, the output file will be generated at
#          generation-time (not configure-time)!
#

include_guard()

##
# @name ex_configure_file( input output [options...] )
# @brief Creates the output file(s) from the input template file and does variable substitution.
# @details Generates the output file(s) with the content of the input template file and always
#          substitutes generator-expressions. If option COPYONLY is given, no extra variables are
#          substituted. If instead option @ONLY is given variables enclosed in @ characters are
#          substituted (as configure_file does it). If neither of these options is present,
#          normal variables as well es those enclosed in @ charaters will be substituted, too.
# @param input The path to the input file which is the template for the output file(s).
# @param output The path to the output file(s) which will be generated from the input.
# @param options... One of the options of `configure_file`, except for NEWLINE_STYLE.
# @note Generator-expressions in the output filename will be expanded.
# @note Likewise, generator-expression in the content of the input template file will be expanded,
#       too, if option COPYONLY was not given.
# @note This function does not create the output file until the generation phase. The output file
#       will not yet have been written when this function returns, it is written only after
#       processing all of a project’s CMakeLists.txt files!
#
function( ex_configure_file input output )
    cmake_parse_arguments(
         "_"
         "COPYONLY;ESCAPE_QUOTES;@ONLY"
         ""
         "NEWLINE_STYLE"
         ${ARGN} )
    if (${__NEWLINE_STYLE})
        message( SEND_ERROR "configure_option's NEWLINE_STYLE option is not allowed for ex_configure_option!" )
    endif()
    if (${__UNPARSED_ARGUMENTS})
        message( SEND_ERROR "ex_configure_option called with unknown arguments!" )
    endif()
    if (${__ESCAPE_QUOTES})
        set( __ESCAPE_QUOTES "ESCAPE_QUOTES" )
    else()
        unset( __ESCAPE_QUOTES )
    endif()
    if (${__\@ONLY})
        set( __\@ONLY "\@ONLY" )
    else()
        unset( __\@ONLY )
    endif()

    if (${__COPYONLY})
        file( GENERATE OUTPUT "${output}" INPUT "${input}" )
    else()
        file( READ "${input}" input_content )
        string( CONFIGURE "${input_content}" input_content ${__ESCAPE_QUOTES} ${__\@ONLY} )
        file( GENERATE OUTPUT "${output}" CONTENT "${input_content}" )
    endif()
    set_property( SOURCE "${output}" PROPERTY GENERATED 1)
endfunction()
