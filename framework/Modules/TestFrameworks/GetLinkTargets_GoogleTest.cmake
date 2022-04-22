##
# @file
# @brief Returns the list of targets that must be linked when using GoogleTest as test-framework.
# @note The returned target contains the `main` function!
#

# "Return" requested list by setting variable TEST_FRAMEWORK_LINK_TARGETS.
set( TEST_FRAMEWORK_LINK_TARGETS "GoogleTest::gtest_main" )
