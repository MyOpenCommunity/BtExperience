import QtQuick 1.1
import Components.Settings 1.0
import BtExperience 1.0


SystemPage {
    source: global.guiSettings.skin === GuiSettings.Clear ? "images/home/home.jpg" :
                                                            "images/home/home_dark.jpg"
    text: qsTr("Settings")
    rootColumn: Component { SettingsItems {} }
    names: SettingsNames {}
}

