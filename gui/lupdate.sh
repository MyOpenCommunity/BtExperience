#!/bin/sh -x


# locating this script; see http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_PATH="$(cd -P $(dirname "$0"); pwd)"

# update translation files for qml sources
lupdate "${SCRIPT_PATH}" -extensions qml -ts "${SCRIPT_PATH}"/locale/bt_experience_it.ts

echo "End of script"
