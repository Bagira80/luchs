# Installing build-artifacts

Installing build-artifacts can be done by using the `cmake --install` command. If you do not want
to install all build-artifacts it is best to use the "component-wise" install using some of the
meta install-components (`RUNTIME`, `DEVELOPMENT`, `PLUGINS`, `DEBUGSYMBOLS`), e.g.:

```
cmake --install <build-dir> --prefix <install-prefix> --component RUNTIME
```

This, for example, would install all the individual "`*-Runtime`" components with a simple
command. Similar, you can install all the individual "`*-Development`" components by using the
`DEVELOPMENT` meta install-component (and so forth).  
But you could also just install the "`*-Runtime`" component of a single project `Foo.Bar` like
this:

```
cmake --install <build-dir> --prefix <install-prefix> --component Foo::Bar-Runtime
```

Whatever components you want to install, those first have to be "registered" with CMake for
installation.


## Preparations for installing project targets and packages

Similar to how _luchs_ simplified the creation of targets with common settings, it also provides
dedicated commands for making these targets installable in a simple way.

First, associate these targets with some of the three install-components, `RUNTIME`, `DEVELOPMENT`
and `PLUGINS`,  by registering them with `register_project_targets`:

```cmake
register_project_targets(
    RUNTIME
        ${project_export_fullname}  # Default target!
    DEVELOPMENT
        Foo::bar
    PLUGINS
        # N/A
)
```

> **Note**: Debug-symbols of targets, that were registered for the `RUNTIME` or `DEVELOPMENT`
> install-component, are always automatically associated with the `DEBUGSYMBOLS`
> install-component.

Afterwards you can make these targets and their debug-symbols installable with
 `install_project_targets` and `install_project_debugsymbols`:

```cmake
install_project_targets()
if (ENABLE_SEPARATE_DEBUGSYMBOLS)
    install_project_debugsymbols()
endif()
```

Instead of calling `register_projects_targets` beforehand, one could also just call
`install_project_targets` with the same arguments, which would implicitly register the given
targets, too. However, calling `register_project_targets` beforehand is recommended!

In general, one does not only want to install these build-artifacts but also some CMake scripts,
including the package-config, in order to import such installed targets via CMake's `find_package`
command. For this you need the functions `generate_project_scripts`, `install_project_exportsets`
and `install_project_packageconfig`:

```cmake
# Install export-sets for RUNTIME and DEVELOPMENT install-components.
generate_project_scripts( DEPENDENCY_LOADER "${CMAKE_CURRENT_BINARY_DIR}/DepsLoader.cmake" )
install_project_exportsets( RUNTIME "${CMAKE_CURRENT_BINARY_DIR}/DepsLoader.cmake" )
install_project_exportsets( DEVELOPMENT "${CMAKE_CURRENT_BINARY_DIR}/DepsLoader.cmake" )
# Install package-config for the current project.
generate_project_scripts( PACKAGE_CONFIG "${CMAKE_CURRENT_BINARY_DIR}/PackageConfig.cmake" )
install_project_packageconfig( "${CMAKE_CURRENT_BINARY_DIR}/PackageConfig.cmake" )
```

As a result, this makes the export-sets for the `RUNTIME` and `DEVELOPMENT` install-components and
associated package-config installable. The filename, under which these will be installed, is
determined by the project-variable `${project_component_prefix_fullname}` with colons replaced by
underscores. Its version is taken from the project's version (`${PROJECT_VERSION}`).  
Another CMake build-project which tries to consume this package will then have to use that name
(and version) in the call to CMake's `find_package` command in order to look for that package.


## Installing a group-package for bundling other projects' packages

It might be advisable to bundle several such packages with another "group"-package and treat them
as "components" of that group-package. This would allow `find_package` to look for the
group-package and import the bundled packages using the `COMPONENTS` and `OPTIONAL_COMPONENTS`
options of the `find_package` command.  
In order to do so, one first has to create and install such a group-package in one CMake project
using the `install_project_grouppackageconfig` function before other projects can bundle their
package with that group-package:

```cmake
install_project_grouppackageconfig( group_name )
```

> **Note**: It might be advisable to use the project-variable `${group_package_dirname}` as
> group-name, because it will probably be the same for all projects. (Of course, this only makes
> sense if there is only ever one group-package with which all other packages will be bundled.)

Afterwards, other projects can bundle their packages with that group-package by using the
`GROUP_PACKAGE` option of `install_project_packageconfig` or rely on a properly set variable
`LUCHS_DEFAULT_GROUP_PACKAGE`:

```cmake
...

install_project_packageconfig( "${CMAKE_CURRENT_BINARY_DIR}/PackageConfig.cmake"
                               GROUP_PACKAGE ${group_package_dirname} )
```

or

```cmake
set( LUCHS_DEFAULT_GROUP_PACKAGE ${group_package_dirname} )
...

install_project_packageconfig( "${CMAKE_CURRENT_BINARY_DIR}/PackageConfig.cmake" )
```
