#!/bin/sh -x


# locating this script; see http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_PATH="$(cd -P $(dirname "$0"); pwd)"

# update translation files for qml sources
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_en.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_it.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_fr.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_de.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_el.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_es.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_nl.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_pt.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_pl.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_ru.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_tr.ts
lupdate "${SCRIPT_PATH}"/.. -extensions qml,js,cpp -ts "${SCRIPT_PATH}"/locale/bt_experience_zh_CN.ts

echo "End of script"
