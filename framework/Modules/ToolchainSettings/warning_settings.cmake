##
# @file
# @details This file defines functions which enable different warnings and (might treat them as
#          errors).
#          * A function that enables (pedantic) compiler warnings and treats them as errors.
#


##
# @name enable_default_compiler_warnings_as_errors( [LANGUAGES <lang> [<lang>...]])
# @brief Enables a lot of (pedantic) compiler warnings and treats them as compiler errors.
# @param LANGUAGES The list of programming languages for which the warnings will be enabled (and
#        treated as errors). If not given defaults to C and C++.
#
function( enable_default_compiler_warnings_as_errors )
    set( function "enable_default_compiler_warnings_as_errors" )
    set( supported_languages "C;CXX" )
    cmake_parse_arguments(
        "_luchs"
        ""
        ""
        "LANGUAGES"
        ${ARGN} )
    # 1. Some sanity checks.
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        message( SEND_ERROR "${function}: Missing languages for option 'LANGUAGES'." )
    elseif (DEFINED _luchs_LANGUAGES)
        foreach (lang IN LISTS _luchs_LANGUAGES)
            if (NOT ${lang} IN_LIST supported_languages)
                message( SEND_ERROR "${function}: Cannot enable warnings for unsupported language '${lang}'." )
            endif()
        endforeach()
    endif()
    # 2. Use default languages if none given.
    if (NOT DEFINED _luchs_LANGUAGES)
        set( _luchs_LANGUAGES "C;CXX" )  # Enable for C and C++ by default!
    endif()
    # 3. Enable warnings as errors for the given languages.
    set( IF_C_GNU_FRONTEND    "$<AND:$<COMPILE_LANG_AND_ID:C,GNU,Clang>,$<OR:$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_C_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_CXX_GNU_FRONTEND  "$<AND:$<COMPILE_LANG_AND_ID:CXX,GNU,Clang>,$<OR:$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_C_MSVC_FRONTEND   "$<AND:$<COMPILE_LANG_AND_ID:C,MSVC,Clang>,$<OR:$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},MSVC>,$<STREQUAL:x${CMAKE_C_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_CXX_MSVC_FRONTEND "$<AND:$<COMPILE_LANG_AND_ID:CXX,MSVC,Clang>,$<OR:$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},MSVC>,$<STREQUAL:x${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},x>>>" )
    if (C IN_LIST _luchs_LANGUAGES)
        add_compile_options( $<${IF_C_GNU_FRONTEND}:-pedantic$<SEMICOLON>-pedantic-errors$<SEMICOLON>-Werror=pedantic> )
        add_compile_options( $<${IF_C_GNU_FRONTEND}:-Wall$<SEMICOLON>-Werror=all> )
        add_compile_options( $<${IF_C_GNU_FRONTEND}:-Wextra$<SEMICOLON>-Werror=extra> )
        add_compile_options( $<${IF_C_MSVC_FRONTEND}:/W4$<SEMICOLON>/WX> )
    endif()
    if (CXX IN_LIST _luchs_LANGUAGES)
        add_compile_options( $<${IF_CXX_GNU_FRONTEND}:-pedantic$<SEMICOLON>-pedantic-errors$<SEMICOLON>-Werror=pedantic> )
        add_compile_options( $<${IF_CXX_GNU_FRONTEND}:-Wall$<SEMICOLON>-Werror=all> )
        add_compile_options( $<${IF_CXX_GNU_FRONTEND}:-Wextra$<SEMICOLON>-Werror=extra> )
        add_compile_options( $<${IF_CXX_MSVC_FRONTEND}:/W4$<SEMICOLON>/WX> )
    endif()
endfunction()
