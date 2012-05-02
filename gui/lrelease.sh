#!/bin/sh -x


# locating this script; see http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_PATH="$(cd -P $(dirname "$0"); pwd)"

# release translation files for qml sources
lrelease "${SCRIPT_PATH}"/locale/*.ts

echo "End of script"
