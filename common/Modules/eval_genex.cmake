##
# @file
# @details Defines a function which tries to evaluate generator-expressions and returns the result.
#

include_guard()

##
# @name eval_genex( <return-variable> <generator-expression> )
# @brief Tries to evaluate the given generator-expression and returns the result.
# @details In order to evaluate the given generator-expression another CMake configure / build
#          process is initiated in which it will be evaluated.
#          However, depending on the complexity of the generator-expression the evaluation might
#          result in an correct or incorrect result. (Test it for each generator-expression!)
#          Especially, when configuring with a multi-configuration generator the result might be
#          incorrect if the generator-expression depends on the build-configuration, because only
#          the default/first configuration will be used during evaluation.
# @param <return-variable> The variable which will be set (in the caller's scope) to the result
#        of the evaluated generator-expression.
# @param <generator-expression> The generator-expression that shall be evaluated.
#

function(eval_genex return_variable expression)
    # 1. Create a temporary directory-name.
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E sha1sum "${CMAKE_CURRENT_LIST_FILE}"
        OUTPUT_VARIABLE temp_dirname
    )
    string(REGEX REPLACE "[ ].*$" "" temp_dirname "${temp_dirname}")  # Only keep hash!
    string(PREPEND temp_dirname "eval_genex-")  # Add identifying prefix to the name.

    # 2. Create a temporary working-directory.
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/${temp_dirname}/build"
    )

    # 3. Create a temporary CMakeLists.txt file.
    file(CONFIGURE @ONLY
        OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${temp_dirname}/CMakeLists.txt"
        CONTENT "# Auto-generated file. DO NOT EDIT!
cmake_minimum_required(VERSION @CMAKE_MINIMUM_REQUIRED_VERSION@)
project(eval_genex-helper VERSION @CMAKE_VERSION@)
add_library(eval_genex-helper-lib INTERFACE)
set_target_properties(eval_genex-helper-lib PROPERTIES \"TO_BE_EVALUATED\" \"@expression@\")
add_custom_target(eval_genex ALL
    COMMAND ${CMAKE_COMMAND} -E echo
            \"$<TARGET_GENEX_EVAL:eval_genex-helper-lib,$<TARGET_PROPERTY:eval_genex-helper-lib,TO_BE_EVALUATED>>\"
)"
    )

    # 4. Configure the temporary CMakeLists.txt (and thereby evaluate the generator-expression).
    set(options)
    # Use same compilers.
    if (DEFINED CMAKE_CXX_COMPILER)
        list(APPEND options "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
    endif()
    if (DEFINED CMAKE_C_COMPILER)
        list(APPEND options "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
    endif()
    # Use same (default) build configuration type.
    get_cmake_property( is_multi_config_generator GENERATOR_IS_MULTI_CONFIG )
    if (is_multi_config_generator)
        list(GET CMAKE_CONFIGURATION_TYPES 0 config_type)
    elseif(DEFINED CMAKE_BUILD_TYPE)
        set(config_type ${CMAKE_BUILD_TYPE})
    endif()
    if (NOT ${config_type} STREQUAL "")
        list(APPEND options " -D${config_type}")
    endif()
    # "Configure" and thereby evaluate the generator-expression.
    execute_process(
        COMMAND ${CMAKE_COMMAND} ${options} ..
        WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${temp_dirname}/build"
        RESULT_VARIABLE exit_code
        OUTPUT_QUIET
        ERROR_VARIABLE error
    )

    # 5. "Build" the temporary CMakeLists.txt and thereby obtain the result of the evaluated generator-expression.
    if (exit_code EQUAL 0)
        set(options)
        if (NOT ${config_type} STREQUAL "")
            list(APPEND options "--config" "${config_type}")
        endif()
        # "Build" and thereby obtain the result of the evaluated generator-expression.
        execute_process(
            COMMAND ${CMAKE_COMMAND} --build . ${options}
            WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${temp_dirname}/build"
            RESULT_VARIABLE exit_code
            OUTPUT_VARIABLE result
            ERROR_VARIABLE  error
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_STRIP_TRAILING_WHITESPACE
        )
        string(REGEX REPLACE "\nBuilt target eval_genex" "" result "${result}")  # Strip boiler-plate.
    endif()
    if (NOT exit_code EQUAL 0)
        message(SEND_ERROR "eval_genex: Unable to evaluate generator-expression. Original error:\n${error}")
        set(result "${expression}")  # Return the non-evaluated generator-expression!
    endif()

    # 6. Remove the temporary working directory again.
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E rm -rf "${CMAKE_CURRENT_BINARY_DIR}/${temp_dirname}"
    )

    # 7. Return the result of the evaluation of the generator-expression.
    set( ${return_variable} "${result}" PARENT_SCOPE )
endfunction()
