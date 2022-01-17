# Getting started

_luchs_ is a CMake support framework that, in general, should be customized for your code-project,
company or product before using it for a new CMake project. Therefore it is recommended to fork
the [original repository](https://github.com/Bagira80/luchs) of _luchs_, customize the fork (see
[Customization](08_customization.md)) and then reference it from your CMake project in which you
want to use it.

In general, it is best to reference _luchs_ via a Git submodule and clone it into a directory
`.luchs` at the top-level directory of that CMake project.

Alternatively, it can automatically be fetched from the Git repository using CMake's
[FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) module during the
"configure" step when cmaking that project.


## Choosing a build toolchain

Choosing a build toolchain (compiler, linker etc.) for a CMake project that uses _luchs_ is not
different to choosing a build toolchain for any CMake project. It can either by selected
automatically by CMake (which takes reasonable defaults depending on the build environment) or one
can provide a build toolchain manually, by setting the `CMAKE_CXX_COMPILER` and similar variables
by hand or by providing an explicit toolchain file which contains values for these variables.

**It is recommended to manually select a build toolchain by providing a toolchain file!**

> Note: It is highly recommended to use one of the toolchain files provided by _luchs_, which can
> be found in the `toolchains` directory of _luchs_.

The call to CMake will then look similar to this:

```
cmake -G "Ninja Multi-Config" --toolchain path/to/toolchain/file -S source-dir -B build-dir
```

Note, that it is especially recommended to manually provde a toolchain file when using the `Ninja`
or `Ninja Multi-Config` generator. If using one of the `Visual Studio` generators the automatic
configuration by CMake should be fine. (Besides, CMake provides additional options for determining
target architecture and toolchain when using one of the `Visual Studio` generators.)

Besides using toolchain files for configuring the build some environment variables and CMake
options can have an impact on the build toolchain. Those are mentioned in sections
["Environment variables"](04_env-variables.md) and ["Configuration options"](05_options.md).


## How to integrate luchs into a CMake project?

In order for any CMake project to be able to use the _luchs_ CMake support framework, _luchs_
first must be found and integrated by that CMake project.

This is done by loading the _luchs_ root-preamble script at the beginning of that CMake project's
top-level `CMakeLists.txt` file:

```cmake
# CMake 3.25 is the minimal requirement for the luchs CMake support framework,
# but it might benefit from newer versions as well (e.g. CMake 3.30).
cmake_minimum_required( VERSION 3.25...3.30 )

# Load preamble with root preparations.
include( "luchs/root-preamble.cmake" )
```

This requires that a subdirectory `luchs` must exist at the top-level directory of that CMake
project which must contain the file `root-preamble.cmake` (for which you can find an example in
the `examples` subdirectory of _luchs_).

By including the root-preamble the CMake project then gets aware of all the scripts which _luchs_
consists of and is ready to use the functionality that _luchs_ provides.


## Declaring a new project

As CMake always requires to declare a "project" as soon as possible, this is what should be done
next. The beginning of the top-level `CMakeLists.txt` will therefore look something like the
following:

```cmake
# CMake 3.25 is the minimal requirement for the luchs CMake support framework,
# but it might benefit from newer versions as well (e.g. CMake 3.30).
cmake_minimum_required( VERSION 3.25...3.30 )

# Load preamble with root preparations.
include( "luchs/root-preamble.cmake" )

# The current project.
include( "common-project-pre-actions" )
project( ${project_name}
         VERSION "${project_version}"
         DESCRIPTION "${project_description}"
         HOMEPAGE_URL "${project_homepage}"
)
include( "common-project-post-actions" )
```

The above mentioned subdirectory `luchs` must therefore not only contain the `root-preamble.cmake`
file but at least also a file called `project-info.cmake` that contains information about the
current project. (For this you can also find an example in the `examples` subdirectory of
_luchs_.)  
That script will automatically be loaded by the `common-project-pre-actions` script which then
provides the variables that are given to the `project` command. The `common-project-post-actions`
script makes some additional adjustments which are required for properly using _luchs_.

Any other `CMakeLists.txt` that declares a CMake (sub-)project (by calling CMake's `project`
command) should begin the same, though the lines which load the root-preamble and set the minimal
required CMake version can be omitted if it does not make sense for that file to ever possibly act
as the top-level `CMakeLists.txt`.  
Of course, that other `CMakeLists.txt` file must come with its own `luchs` subdirectory (located
next to it) in which its `project-info.cmake` file (and possibly the `root-preamble.cmake` file)
resides.


## Declaring project targets

In order to simplify the creation of executable or library targets with common settings, dedicated
commands `add_project_executable` and `add_project_library` are provided.

Each of these creates a new target, an additional alias target with proper namespace (taken from
the project's `project-info.cmake` file), associates the project's version number with it, properly
sets include-search-paths and modifies its properties in such a way that IDEs properly display this
target with its alias name.

Additionally, each command automatically reads in specific files (if available) that contain the
list of public and private sources needed to build the target and adds these as sources to the
target. (This allows to keep the list of sources for a target outside the `CMakeLists.txt` file.)  
These specific files with the list of public/private sources must be located in the `luchs`
subdirectory of the current project as well and must be named
`project-sources_-_<identifier>_-_public.cmake` for public sources (aka header files) and
`project-sources_-_<identifier>_-_private.cmake` for private sources.  
The placeholder `<identifier>` needs to be replaced either by the entire name of the target or, in
case the target's name has the form `${PROJECT_NAME}-<name>`, only by the `<name>` part of the
target's name.


### Format for files containing lists of public/private sources

The files that contain the list of public and private sources must adhere to a specific format.
* Its entire content must be enclosed in a CMake
  [bracket-comment](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#bracket-comment)
  (aka a block-comment).
* Each line starting with a `#` or entirely empty is interpreted as a comment and ignored.
* Each source file must be listed on its own line, either with absolute path or relative to the
  current `CMakeLists.txt` (aka `${CMAKE_CURRENT_SOURCE_DIR}`).
* CMake variable substitution and generator-expressions are supported.

Example of a file containing public sources (aka headers):

```cmake
#[====================[
# Public sources for target: <identifier>
#
# Generated source files:
${PROJECT_BINARY_DIR}/include/${project_folder_fullname}/header1.hpp
# Non-generated source files:
include/${project_folder_fullname}/header2.hpp
include/${project_folder_fullname}/header3.hpp
#]====================]
```

Example of a file containing private sources:

```cmake
#[====================[
# Private sources for target: <identifier>
#
# Generated source files:
${PROJECT_BINARY_DIR}/src/${project_folder_fullname}/source1.cpp
${PROJECT_BINARY_DIR}/src/${project_folder_fullname}/source2_$<CONFIG>.cpp
# Non-generated source files:
src/${project_folder_fullname}/source3.cpp
#]====================]
```

## Declaring project tests (and test-targets)

Similar to before, a new command `add_project_test` is also provided which simplifies the creation
of a test executable with common settings and automatically registers it as a new test. (It pretty
much combines `add_project_executable` with CMake's `add_test` command.)

The list of its private and public sources can automatically be added as described in the former
section regarding `add_project_executable`.  
However, this command takes some additional options which among other things can automatically load
a test-framework and link against it. (Currently, only "GoogleTest" is supported but others can
easily be added.) A default test-framework can be set for all such tests by using the
`LUCHS_DEFAULT_TEST_FRAMEWORK` variable. (A value of `NONE` describes the absense of such a
test-framework.)

