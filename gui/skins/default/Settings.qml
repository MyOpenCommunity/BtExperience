import QtQuick 1.1
import Components.Settings 1.0


SystemPage {
    source: "images/illuminazione.jpg"
    text: qsTr("Settings")
    rootColumn: Component { SettingsItems {} }
    names: SettingsNames {}
}

