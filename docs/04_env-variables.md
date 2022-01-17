# Special environment variables

Some environment variables have special meaning for _luchs_. In general, they are prefixed with
`LUCHS_`. However, some environment-variables that are used are not specifically prefixed at all.


## Environment variables for finding _luchs_ itself

The `luchs/root-preamble.cmake` file (for which you can find an example in the `examples`
directory) looks at several places for _luchs_. It first checks for the existance of some
environment variables and only if these are not defined will look for a directory `.luchs`
at the top-level directory of the software project that is currently getting built or will try
to fetch it from the default Git server.

The environment variables which are checked first, are the following:


### `LUCHS_FRAMEWORK_LOCAL_PATH`

Determines the path to the directory on the filesystem where _luchs_ is located. If found, no
other environment variable will be checked for finding _luchs_.


### `LUCHS_FRAMEWORK_GIT_REPOSITORY`

Determines the path to the Git repository (server) from which _luchs_ shall be cloned. If found,
the following environment variable will still be checked as well.


### `LUCHS_FRAMEWORK_GIT_TAG`

Determines the tag, branch or commit hash that shall be checked out from the Git repository
(server). This variable is only considered if _luchs_ shall be cloned from a Git repository
(whether from the one determined by `LUCHS_FRAMEWORK_GIT_REPOSITORY` or from the default one).
If it is not found, the default branch (`main`) will be cloned instead.


## Environment variables for finding dependencies

Similar to finding _luchs_ itself, finding a common dependency also first considers similar named
environment variables before trying to load it from some fixed location or cloning it from some
Git repository.


### `LUCHS_DEPENDENCY_<name>_LOCAL_PATH`

Determines the path to the directory on the filesystem where dependency `<name>` is located. If
found, no other environment variable will be checked for finding dependency `<name>`.


### `LUCHS_DEPENDENCY_<name>_GIT_REPOSITORY`

Determines the path to the Git repository (server) from which dependency `<name>` shall be
cloned. If found, the following environment variable will still be checked as well.


### `LUCHS_DEPENDENCY_<name>_GIT_TAG`

Determines the tag, branch or commit hash that shall be checked out from the Git repository
(server). This variable is only considered if dependency `<name>` shall be cloned from a Git
repository (whether from the one determined by `LUCHS_DEPENDENCY_<name>_GIT_REPOSITORY` or
from the default one). If it is not found, the default branch will be cloned instead.


## Other environment variables

Some other environment variables are also considered by _luchs_. Often, these should be set on CI
systems by the build job.


### `CURRENT_BUILD_NUMBER`

The environment variable `CURRENT_BUILD_NUMBER` is supposed to carry a non-negative integer and
will be interpreted as a build number. It will be treated as the forth component of a
[semver](https://semver.org/) version number, in particular for (Windows) resource files. (Note,
however, that it is not used as value for CMake's `PROJECT_VERSION_TWEAK` variable!)

If that environment variable does not exist a simple `0` will be assumed instead and used
internally.

> **Note**: Normally, this environment variable should only be set on CI systems by the build job.
