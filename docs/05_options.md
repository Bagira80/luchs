# Configuration options

_luchs_ automatically registers several CMake options within the CMake project it is integrated
with. Those alter how CMake will configure the build. They can either be provided directly via the
command-line when calling the `cmake` executable or they can be set in a more graphical fashing
using `ccmake` or `cmake-gui`.

Besides the well-known options that are directly provided by CMake (e.g.
[`CMAKE_BUILD_TYPE`](https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html) for
single-config generators,
[`CMAKE_INSTALL_PREFIX`](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html),
[`CMAKE_CXX_FLAGS`](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_FLAGS.html) and all
the other ones) some additional options are provided:


## Options regarding optimization

### `ENABLE_LTO`

If set to `TRUE`, link-time optimization will be used. This should result in creating more heavily
optimized (shared) libraries and executables.


### `ENABLE_BUILDING_WITH_TIME_TRACE_PROFILING`

If set to `TRUE`, building will also generate report files with profiling information about where
and for how long the build process spent its time building. (It might help optimizing compilation
times.)

> **Note**: This is not supported by all compilers!

For more information you can consult the following resources:
* https://aras-p.info/blog/2019/01/12/Investigating-compile-times-and-Clang-ftime-report/
* https://aras-p.info/blog/2019/01/16/time-trace-timeline-flame-chart-profiler-for-Clang/
* https://www.snsystems.com/technology/tech-blog/clang-time-trace-feature

And somehow related:
* https://devblogs.microsoft.com/cppblog/introducing-vcperf-timetrace-for-cpp-build-time-analysis/


## Options regarding debugging

### `ENABLE_SEPARATE_DEBUGSYMBOLS`

If set to `TRUE`, debug-symbols will be generated in files of their own. Otherwise, they will be
stored directly in the generated libraries/executables.

> **Note**: On Windows it might not entirely be possible to prevent generating separate debug-symbols
  files.


### `ENABLE_REMOVING_FULLPATH_TO_PDB_FROM_DLL_AND_EXE`

If set to `TRUE`, debug-symbols on Windows (aka `*.pdb` files) will only contain the name of the
associated DLL or executable but not the full path to it.

> **Note**: On Linux this option has no relevance.


## Options regarding execution


### `USE_DEFAULT_INSTALL_RPATH`

If set to `TRUE`, the `RPATH` stored within shared libraries and executables on Linux will use
the default installation run-path. Therefore, the dynamic loader will search for shared libraries
in those directories when these binaries are loaded.

> **Note**: On Windows this option has no relevance.


### `ENFORCE_MINIMAL_SUPPORTED_WINDOWS_VERSION`

If set to `TRUE`, executables on Windows will refuse to start if the used Windows version is too
old.

> **Note**: On Linux this option has no relevance.


## Correctness related options

Individual options exist for different _sanitizers_. However, not all sanitizers are supported by
all compilers. So not all of the following options might be available. It also might not be
possible or sensible to enable multiple sanitizers together. (You will have to try it out.)

> **Note**: Your targets have to declare a dependency (via CMake's `target_link_libraries`
> command) against the `sanitizer` target in order to be built with sanitizer support!


### `SANITIZER_ASan`

If set to `TRUE`, enable building with _address sanitizer_ (ASan).

### `SANITIZER_LSan`

If set to `TRUE`, enable building with _leak sanitizer_ (LSan).

### `SANITIZER_MSan`

If set to `TRUE`, enable building with _memory sanitizer_ (MSan).

### `SANITIZER_TSan`

If set to `TRUE`, enable building with _thread sanitizer_ (TSan).

### `SANITIZER_UBSan`

If set to `TRUE`, enable building with _undefined-behavior sanitizer_ (UBSan).


## CMake variables which must be provided explicitly by the CMake project

_luchs_ has some mechanisms to use some settings for which it does not provide dedicated CMake
options. A lot of these are (global) CMake variables:

### `LUCHS_DEFAULT_TEST_FRAMEWORK`

A CMake variable which determines the test-framework that should be used by default for test-cases
created with the `add_project_test` command.

> **Note**: This can be overridden when calling `add_project_test` by providing the name of a
> different test-framework (or `NONE`) through the `TEST_FRAMEWORK` parameter.

Currently, only "GoogleTest" is supported but other test-frameworks can easily be added to _luchs_
and then used as default test-framework.  
Providing a value of `NONE` is describing the absence of a default test-framework. (Not providing
the `LUCHS_DEFAULT_TEST_FRAMEWORK` variable is similar to providing it with a value of `NONE`.)


### `LUCHS_DEFAULT_GROUP_PACKAGE`

Similar, this is a CMake variable which determines the default name of a group-package. When CMake
package-configs (aka the "CMake import-scripts") will be (prepared to be) installed via
`install_project_packageconfig`, this variable determines the name of the CMake package with which
it will be associated, which is the name that will be used in a call to CMake's `find_package`
command.

> **Note**: This can be overridden when calling `add_project_packageconfig` by providing the name
> of a different group-package (or `NONE`) through the `GROUP_PACKAGE` parameter.


## Preprocessor macros which must be provided explicitly by the CMake project

Some mechanisms of _luchs_ require no specific CMake options or variables, but instead require
some specific pre-processor macros that need to be defined when some build step is running. Those
need to be provided by the CMake project which uses _luchs_.

> **Note**: That CMake project could provide convenient CMake options for these settings itself or
> it could just apply the (pre-processor) settings directly when building.


### `OFFICIAL_RELEASE_BUILD`

A pre-processor macro that should be defined if the current build is supposed to become an
official release build.

This will then, for example, instruct the (Windows) resource compiler to use specific flags for
such official release builds.

> **Note**: On CI servers this pre-processor macro should, in general, be defined for the job that
> is responsible to build official release builds!


### `CUSTOMIZED_BUILD`

A pre-processor macro that should be defined to the name of a customer (company) for whom the
build is customized.

This will then, for example, instruct the (Windows) resource compiler to use specific flags for
such a customized build.
