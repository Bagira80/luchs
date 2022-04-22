##
# @file
# @brief Registers tests from a target that uses GoogleTest.
# @details Required variables:
#            * ADD_DISCOVERABLE_TESTS_TARGET
#          Optional variables:
#            * ADD_DISCOVERABLE_TESTS_WORKING_DIRECTORY
#            * ADD_DISCOVERABLE_TESTS_TEST_PREFIX
#            * ADD_DISCOVERABLE_TESTS_TEST_SUFFIX
#            * ADD_DISCOVERABLE_TESTS_ADDITIONAL_OPTIONS
#

# Load GoogleTest helper function if not already loaded.
if (NOT COMMAND gtest_discover_tests)
    include( GoogleTest )
endif()

# Sanity-checks.
if (NOT TARGET "${ADD_DISCOVERABLE_TESTS_TARGET}")
    message( "${CMAKE_CURRENT_FUNCTION}: Cannot register discoverable tests. [Unknown target '${ADD_DISCOVERABLE_TESTS_TARGET}']" )
endif()

# Some preparations.
if (DEFINED ADD_DISCOVERABLE_TESTS_WORKING_DIRECTORY)
    list( PREPEND ADD_DISCOVERABLE_TESTS_WORKING_DIRECTORY "WORKING_DIRECTORY" )
endif()
if (DEFINED ADD_DISCOVERABLE_TESTS_TEST_PREFIX)
    list( PREPEND ADD_DISCOVERABLE_TESTS_TEST_PREFIX "TEST_PREFIX" )
endif()
if (DEFINED ADD_DISCOVERABLE_TESTS_TEST_SUFFIX)
    list( PREPEND ADD_DISCOVERABLE_TESTS_TEST_SUFFIX "TEST_SUFFIX" )
endif()

# Register tests.
gtest_discover_tests( ${name}
    ${ADD_DISCOVERABLE_TESTS_WORKING_DIRECTORY}
    ${ADD_DISCOVERABLE_TESTS_TEST_PREFIX}
    ${ADD_DISCOVERABLE_TESTS_TEST_SUFFIX}
    DISCOVERY_MODE PRE_TEST
)
