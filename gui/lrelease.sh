#!/bin/sh -x


# locating this script; see http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_PATH="$(dirname $(readlink -f $0))"

# release translation files for qml sources
lrelease "${SCRIPT_PATH}"/linguist-ts/*.ts

echo "End of script"
