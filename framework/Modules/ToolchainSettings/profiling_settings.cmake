##
# @file
# @details This file defines functions which enable different profiling settings.
#          * A function that enables time-trace profiling.
#


##
# @name enable_building_with_time_trace_profiling()
# @brief Enables time-trace profiling when building which generates JSON files for inspection.
# @param LANGUAGES The list of programming languages for which time-trace profiling will be
#        enabled. If not given defaults to C and C++.
# @param GRANULARITY The minimum time granularity (in microseconds) traced by the time profiler.
# @note Currently, this is only supported for Clang 9 or newer!
# @note GCC might support this with in the future, too.
#       (See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=92396)
#
function( enable_building_with_time_trace_profiling )
    set( function "enable_building_with_time_trace_profiling" )
    set( supported_languages "C;CXX" )
    cmake_parse_arguments(
        "_luchs"
        ""
        "GRANULARITY"
        "LANGUAGES"
        ${ARGN} )
    # 1. Some sanity checks.
    if (DEFINED _luchs_KEYWORDS_MISSING_VALUES)
        if (LANGUAGES IN_LIST _luchs_KEYWORDS_MISSING_VALUES)
            message( SEND_ERROR "${function}: Missing languages for option 'LANGUAGES'." )
        endif()
        if (GRANULARITY IN_LIST _luchs_KEYWORDS_MISSING_VALUES)
            message( SEND_ERROR "${function}: Missing minimum time granularity (in microseconds) for option 'GRANULARITY'." )
        endif()
    elseif (DEFINED _luchs_LANGUAGES)
        foreach (lang IN LISTS _luchs_LANGUAGES)
            if (NOT ${lang} IN_LIST supported_languages)
                message( SEND_ERROR "${function}: Cannot enable 'time-trace' profiling for unsupported language '${lang}'." )
            endif()
        endforeach()
    endif()
    # 2. Use default languages if none given.
    if (NOT DEFINED _luchs_LANGUAGES)
        set( _luchs_LANGUAGES "C;CXX" )  # Enable for C and C++ by default!
    endif()
    # 3. Make sure a supported compiler (aka Clang) is used.
    foreach (lang IN LISTS _luchs_LANGUAGES)
        if (NOT "${CMAKE_${lang}_COMPILER_ID}" STREQUAL "Clang" OR ${CMAKE_${lang}_COMPILER_VERSION} VERSION_LESS "9")
            message( WARNING "${function}: Cannot enable 'time-trace' profiling for current compiler for language '${lang}'!" )
        endif()
    endforeach()
    # 4. Enable time-trace profiling for the given languages.
    set( IF_C_GNU_FRONTEND    "$<AND:$<COMPILE_LANG_AND_ID:C,Clang>,$<OR:$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_C_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_CXX_GNU_FRONTEND  "$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<OR:$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},GNU>,$<STREQUAL:x${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},x>>>" )
    set( IF_C_MSVC_FRONTEND   "$<AND:$<COMPILE_LANG_AND_ID:C,Clang>,$<STREQUAL:${CMAKE_C_COMPILER_FRONTEND_VARIANT},MSVC>>" )
    set( IF_CXX_MSVC_FRONTEND "$<AND:$<COMPILE_LANG_AND_ID:CXX,Clang>,$<STREQUAL:${CMAKE_CXX_COMPILER_FRONTEND_VARIANT},MSVC>>" )
    if (C IN_LIST _luchs_LANGUAGES)
        add_compile_options( $<${IF_C_GNU_FRONTEND}:-ftime-trace> )
        add_compile_options( $<${IF_C_MSVC_FRONTEND}:/clang:-ftime-trace> )
        if (DEFINED _luchs_GRANULARITY)  # AND (Clang >= 10.0.0)
            add_compile_options( $<$<AND:${IF_C_GNU_FRONTEND},$<NOT:$<C_COMPILER_VERSION:9>>>:-ftime-trace-granularity=${_luchs_GRANULARITY}> )
            add_compile_options( $<$<AND:${IF_C_MSVC_FRONTEND},$<NOT:$<C_COMPILER_VERSION:9>>>:/clang:-ftime-trace-granularity=${_luchs_GRANULARITY}> )
        endif()
    endif()
    if (CXX IN_LIST _luchs_LANGUAGES)
        add_compile_options( $<${IF_CXX_GNU_FRONTEND}:-ftime-trace> )
        add_compile_options( $<${IF_CXX_MSVC_FRONTEND}:/clang:-ftime-trace> )
        if (DEFINED _luchs_GRANULARITY)  # AND (Clang >= 10.0.0)
            add_compile_options( $<$<AND:${IF_CXX_GNU_FRONTEND},$<NOT:$<CXX_COMPILER_VERSION:9>>>:-ftime-trace-granularity=${_luchs_GRANULARITY}> )
            add_compile_options( $<$<AND:${IF_CXX_MSVC_FRONTEND},$<NOT:$<CXX_COMPILER_VERSION:9>>>:/clang:-ftime-trace-granularity=${_luchs_GRANULARITY}> )
        endif()
    endif()
endfunction()
