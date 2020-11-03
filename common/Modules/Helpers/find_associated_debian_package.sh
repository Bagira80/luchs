#!/bin/sh

# Exit on error or unset variables!
set -eu

# Convenience variables for arguments.
SEARCH_FILE=$1
shift
REMAINING_ARGS=$@

# Determine Debian package for given search-file.
package_name=$(dpkg -S $SEARCH_FILE 2>&1)
package_name=$(echo "$package_name" | tail -n 1)
package_name=$(echo $package_name | sed 's/:.*$//')
# Output found package and remaining arguments (if any).
echo $package_name $REMAINING_ARGS
