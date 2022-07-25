##
# @file
# @details This file defines functions which enable different warnings and (might treat them as
#          errors).
#          * A function that enables (pedantic) compiler warnings and treats them as errors.
#          * A function that again disables some specific compiler warnings because they might be
#            problematic.
#          * A function that enables extra linker warnings and treats them as errors.
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


##
# @name disable_problematic_compiler_warnings( [LANGUAGES <lang> [<lang>...]])
# @brief Disables some problematic compiler warnings and no longer treats them as compiler errors.
# @param LANGUAGES The list of programming languages for which some problematic warnings will be
#        disabled (and no longer treated as errors). If not given defaults to C and C++.
#
function( disable_problematic_compiler_warnings )
    set( function "disable_problematic_compiler_warnings" )
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
        foreach( lang IN LISTS _luchs_LANGUAGES )
            if (NOT ${lang} IN_LIST supported_languages)
                message( SEND_ERROR "${function}: Cannot disable warnings for unsupported language '${lang}'." )
            endif()
        endforeach()
    endif()
    # 2. Use default languages if none given.
    if (NOT DEFINED _luchs_LANGUAGES)
        set( _luchs_LANGUAGES "C;CXX" )  # Enable for C and C++ by default!
    endif()
    # 3. Disable some specific warnings again (and not longer treat them as errors) for the given languages.
    set( IF_C_GNU_FRONTEND    "$<AND:$<COMPILE_LANG_AND_ID:C,GNU,Clang>,$<OR:$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_C_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_CXX_GNU_FRONTEND  "$<AND:$<COMPILE_LANG_AND_ID:C,GNU,Clang>,$<OR:$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_C_MSVC_FRONTEND   "$<AND:$<COMPILE_LANG_AND_ID:C,MSVC,Clang>,$<OR:$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},MSVC>,$<STREQUAL:x${CMAKE_C_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_CXX_MSVC_FRONTEND "$<AND:$<COMPILE_LANG_AND_ID:CXX,MSVC,Clang>,$<OR:$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},MSVC>,$<STREQUAL:x${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},x>>>" )
    if (C IN_LIST _luchs_LANGUAGES)
        add_compile_options( $<${IF_C_GNU_FRONTEND}:-Wno-unknown-pragmas$<SEMICOLON>-Wno-error=unknown-pragmas> )
        add_compile_options( $<${IF_C_GNU_FRONTEND}:-Wno-unused-result$<SEMICOLON>-Wno-error=unused-result> )
    endif()
    if (CXX IN_LIST _luchs_LANGUAGES)
        add_compile_options( $<${IF_CXX_GNU_FRONTEND}:-Wno-unknown-pragmas$<SEMICOLON>-Wno-error=unknown-pragmas> )
        add_compile_options( $<${IF_CXX_GNU_FRONTEND}:-Wno-unused-result$<SEMICOLON>-Wno-error=unused-result> )
    endif()
endfunction()


##
# @name enable_default_linker_warnings_as_errors( [LANGUAGES <lang> [<lang>...]])
# @brief Enables extra linker warnings and treats them as linker errors.
# @param LANGUAGES The list of programming languages for which the warnings will be enabled (and
#        treated as errors). If not given defaults to C and C++.
#
function( enable_default_linker_warnings_as_errors )
    set( function "enable_default_linker_warnings_as_errors" )
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
    set( IF_C_GNU_FRONTEND    "$<AND:$<LINK_LANG_AND_ID:C,GNU,Clang>,$<NOT:$<STREQUAL:${CMAKE_C_SIMULATE_ID},MSVC>>>" )
    set( IF_CXX_GNU_FRONTEND  "$<AND:$<LINK_LANG_AND_ID:CXX,GNU,Clang>,$<NOT:$<STREQUAL:${CMAKE_CXX_SIMULATE_ID},MSVC>>>" )
    set( IF_C_MSVC_FRONTEND   "$<AND:$<LINK_LANGUAGE:C>,$<OR:$<C_COMPILER_ID:MSVC>,$<STREQUAL:${CMAKE_C_SIMULATE_ID},MSVC>>>" )
    set( IF_CXX_MSVC_FRONTEND "$<AND:$<LINK_LANGUAGE:CXX>,$<OR:$<CXX_COMPILER_ID:MSVC>,$<STREQUAL:${CMAKE_CXX_SIMULATE_ID},MSVC>>>" )
    set( IS_SHARED_OBJECT     "$<OR:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>,$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>>" )
    set( IS_SANITIZER_ENABLED "$<OR:$<BOOL:${SANITIZER_UBSan}>,$<BOOL:${SANITIZER_ASan}>,$<BOOL:${SANITIZER_LSan}>,$<BOOL:${SANITIZER_TSan}>,$<BOOL:${SANITIZER_MSan}>>" )
    if (C IN_LIST _luchs_LANGUAGES)
        # Treat linker-warnings as errors.
        add_link_options( $<${IF_C_MSVC_FRONTEND}:LINKER:/WX> )
        add_link_options( $<${IF_C_GNU_FRONTEND}:LINKER:--fatal-warnings> )
            # Supported by:     BFD, Gold, LLD, Mold
            # Not supported by: N/A
            # Ignored by:       N/A

        # Enable detection of violations of the C++ One Definition rule.
        #add_link_options( $<${IF_C_GNU_FRONTEND}:LINKER:--detect-odr-violations> )
            # Supported by:     Gold
            # Not supported by: BFD, Mold
            # Ignored by:       LLD

        # Enforce resolving all symbols during linking.
        # Note: Not supported and therefore disabled when linking a shared object using Clang if sanitizer support is enabled.
        add_link_options( $<$<AND:${IF_C_GNU_FRONTEND},$<NOT:$<AND:$<C_COMPILER_ID:Clang>,${IS_SHARED_OBJECT},${IS_SANITIZER_ENABLED}>>>:LINKER:--no-undefined> )
            # Supported by:     BFD, Gold, LLD, Mold
            # Not supported by: N/A
            # Ignored by:       N/A
        add_link_options( $<$<AND:${IF_C_GNU_FRONTEND},$<NOT:$<AND:$<C_COMPILER_ID:Clang>,${IS_SHARED_OBJECT},${IS_SANITIZER_ENABLED}>>>:LINKER:--no-allow-shlib-undefined> )
            # Supported by:     BFD, Gold, LLD
            # Not supported by: N/A
            # Ignored by:       Mold

        # Only actually link needed libraries!
        # Note: This is actually no warning/error, but it fits here best.
        add_link_options( $<${IF_C_GNU_FRONTEND}:LINKER:--as-needed> )
            # Supported by:     BFD, Gold, LLD, Mold
            # Not supported by: N/A
            # Ignored by:       N/A
    endif()
    if (CXX IN_LIST _luchs_LANGUAGES)
        # Treat linker-warnings as errors.
        add_link_options( $<${IF_CXX_MSVC_FRONTEND}:LINKER:/WX> )
        add_link_options( $<${IF_CXX_GNU_FRONTEND}:LINKER:--fatal-warnings> )
            # Supported by:     BFD, Gold, LLD, Mold
            # Not supported by: N/A
            # Ignored by:       N/A

        # Enable detection of violations of the C++ One Definition rule.
        #add_link_options( $<${IF_CXX_GNU_FRONTEND}:LINKER:--detect-odr-violations> )
            # Supported by:     Gold
            # Not supported by: BFD, Mold
            # Ignored by:       LLD

        # Enforce resolving all symbols during linking.
        # Note: Not supported and therefore disabled when linking a shared object using Clang if sanitizer support is enabled.
        add_link_options( $<$<AND:${IF_CXX_GNU_FRONTEND},$<NOT:$<AND:$<CXX_COMPILER_ID:Clang>,${IS_SHARED_OBJECT},${IS_SANITIZER_ENABLED}>>>:LINKER:--no-undefined> )
            # Supported by:     BFD, Gold, LLD, Mold
            # Not supported by: N/A
            # Ignored by:       N/A
        add_link_options( $<$<AND:${IF_CXX_GNU_FRONTEND},$<NOT:$<AND:$<CXX_COMPILER_ID:Clang>,${IS_SHARED_OBJECT},${IS_SANITIZER_ENABLED}>>>:LINKER:--no-allow-shlib-undefined> )
            # Supported by:     BFD, Gold, LLD
            # Not supported by: N/A
            # Ignored by:       Mold

        # Only actually link needed libraries!
        # Note: This is actually no warning/error, but it fits here best.
        add_link_options( $<${IF_CXX_GNU_FRONTEND}:LINKER:--as-needed> )
            # Supported by:     BFD, Gold, LLD, Mold
            # Not supported by: N/A
            # Ignored by:       N/A
    endif()
endfunction()
