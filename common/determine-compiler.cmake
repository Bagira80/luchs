##
# @file
# @details Defines two functions for determining witch C++ compiler is used.
#

include_guard()


##
# @name determine_cxx_compiler_id( out_name )
# @brief Determines the ID of the C++ compiler and stores it in the given variable `out_name`.
# @param out_name The variable in which the determined C++ compiler ID will be stored.
#
function( determine_cxx_compiler_id out_name )
    # Which C++ compiler executable is used?
    if (DEFINED CMAKE_CXX_COMPILER)
        set(cxx_compiler "${CMAKE_CXX_COMPILER}")
    elseif (DEFINED ENV{CXX} AND NOT "$ENV{CXX}" STREQUAL "")
        set(cxx_compiler "$ENV{CXX}")
    else()
        set(cxx_compiler "c++")
    endif()
    # Request the absolute path of the chosen C++ compiler.
    execute_process(COMMAND bash -c "set -o pipefail ; which \"${cxx_compiler}\""
                    TIMEOUT 5
                    RESULT_VARIABLE return_code
                    OUTPUT_VARIABLE cxx_compiler
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT ("${return_code}" EQUAL "0"))
        set(${out_name} "unknown" PARENT_SCOPE)  # Default value.
        message(SEND_ERROR "Cannot determine the compiler's ID! (Consider setting \"CMAKE_CXX_COMPILER\" explicitly.)")
        return()
    endif()

    # Request the name and version of the chosen C++ compiler.
    execute_process(COMMAND bash -c "set -o pipefail ; \"${cxx_compiler}\" --version | head -n 1"
                    TIMEOUT 5
                    RESULT_VARIABLE return_code
                    OUTPUT_VARIABLE stdout
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    # Successful?
    if (NOT "${return_code}" EQUAL "0" OR "${stdout}" STREQUAL "")
        set(${out_name} "unknown" PARENT_SCOPE)  # Default value.

    # Search for known compiler names in output of aforementioned command.
    elseif (("${stdout}" MATCHES "[gG][cC][cC]") OR
            ("${stdout}" MATCHES "[gG][+][+]"))
        set(${out_name} "GNU" PARENT_SCOPE)
    elseif (("${stdout}" MATCHES "[cC][lL][aA][nN][gG]") OR
            ("${stdout}" MATCHES "[lL][lL][vV][mM]"))
        set(${out_name} "Clang" PARENT_SCOPE)

    # Try to extract the compiler name from the name of the executable/symlink.
    elseif (("${cxx_compiler}" MATCHES "[gG][cC][cC]") OR
            ("${cxx_compiler}" MATCHES "[gG][+][+]"))
        set(${out_name} "GNU" PARENT_SCOPE)
    elseif (("${cxx_compiler}" MATCHES "[cC][lL][aA][nN][gG]") OR
            ("${cxx_compiler}" MATCHES "[lL][lL][vV][mM]"))
        set (${out_name} "Clang" PARENT_SCOPE)
    elseif (IS_SYMLINK "${cxx_compiler}")

        # Request the real name of the compiler executable.
        execute_process(COMMAND bash -c "readlink -f \"${cxx_compiler}\""
                        TIMEOUT 5
                        RESULT_VARIABLE return_code
                        OUTPUT_VARIABLE stdout
                        ERROR_QUIET
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
        # Successful?
        if (NOT "${return_code}" EQUAL "0" OR "${stdout}" STREQUAL "")
            set(${out_name} "unknown" PARENT_SCOPE)  # Default value.

        # Try to extract the compiler name from the name of the real executable.
        elseif (("${stdout}" MATCHES "[gG][cC][cC]") OR
                ("${stdout}" MATCHES "[gG][+][+]"))
            set(${out_name} "GNU" PARENT_SCOPE)
        elseif (("${stdout}" MATCHES "[cC][lL][aA][nN][gG]") OR
                ("${stdout}" MATCHES "[lL][lL][vV][mM]"))
            set(${out_name} "Clang" PARENT_SCOPE)
        else()
            set(${out_name} "unknown" PARENT_SCOPE)  # Default value.
        endif()
    else()
        set(${out_name} "unknown" PARENT_SCOPE)  # Default value.
    endif()
endfunction()


##
# @name determine_cxx_compiler_version( out_name )
# @brief Determines the version of the C++ compiler and stores it in the given variable `out_name`.
# @param out_name The variable in which the determined C++ compiler version will be stored.
#
function( determine_cxx_compiler_version out_name )
    # Which C++ compiler executable is used?
    if (DEFINED CMAKE_CXX_COMPILER)
        set(cxx_compiler "${CMAKE_CXX_COMPILER}")
    elseif (DEFINED ENV{CXX} AND NOT "$ENV{CXX}" STREQUAL "")
        set(cxx_compiler "$ENV{CXX}")
    else()
        set(cxx_compiler "c++")
    endif()

    # Request the name and version of the chosen C++ compiler.
    execute_process(COMMAND bash -c "set -o pipefail ; \"${cxx_compiler}\" --version | head -n 1"
                    TIMEOUT 5
                    RESULT_VARIABLE return_code
                    OUTPUT_VARIABLE stdout
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Successful?
    if (NOT "${return_code}" EQUAL "0" OR "${stdout}" STREQUAL "")
        set(${out_name} "0.0.0" PARENT_SCOPE)  # Default value.

    # Try to extract version number.
    elseif ("${stdout}" MATCHES "[0-9]+([.][0-9]+)+")
        string(REGEX MATCH "[0-9]+([.][0-9]+)+" version "${stdout}")
        set(${out_name} "${version}" PARENT_SCOPE)
    else()
        set(${out_name} "0.0.0" PARENT_SCOPE)  # Default value.
    endif()
endfunction()
