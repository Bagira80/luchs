# Packaging build-artifacts

Everything that was prepared to be installed can be packaged into an archive (e.g. `tar.gz`, `zip`
etc.) or into other package types for different packaging systems or installers.

> **Note**: Currently, only some package archives and Debian packages are supported.

One can use the `CPACK_BINARY_<package-type>` CMake cache-variables to enable packaging into a
specific package type.

Extending the `CMakeLists.txt` file with the functionality for packaging its targets is then quite
simple. One only has to add the following line at the end of the `CMakeLists.txt` file:

```cmake
add_project_packaging_subdirectory()
```

This makes all preparations needed for packaging. If one really wants to provide the functionality
oneself, one can instead create a subdirectory `packaging` in the directory where the current
`CMakeLists.txt` resides and put another `CMakeLists.txt` script into it which contains all the
manual preparations for packaging.  
However, in general, this should not be needed and the automatically used preparations should be
sufficient.

The packages can then be created by explicitly running the `cpack` executable or by triggering it
through the `cmake` executable which then builds all packages:

```
cmake --build <build-dir> --target package
```

All the packages can then be found in subdirectory `<build-dir>/packages` (possibly in another
subdirectory with the name of the current build-configuration).
