#!/bin/sh

# Exit on error or unset variables!
set -eu

# Convenience variables for arguments.
SEARCH_FILE=$1
shift
REMAINING_ARGS=$@

# Determine Debian package for given search-file.
package_name=$(dpkg-query -S $SEARCH_FILE 2>&1)
package_name=$(echo "$package_name" | tail -n 1)
package_name=$(echo $package_name | sed 's/:.*$//')

# Output remaining arguments if no package found and return.
if [ -z "$package_name" ]; then
    echo "\t\t$REMAINING_ARGS"
    return
fi

# Determine version of Debian package.
package_version=$(dpkg-query --showformat='${Version}' --show $package_name)
# Output found package/version and remaining arguments (if any).
if [ -z "$package_version" ]; then
    echo "$package_name\t$REMAINING_ARGS"
else
    echo "$package_name\t$package_version\t$REMAINING_ARGS"
fi
