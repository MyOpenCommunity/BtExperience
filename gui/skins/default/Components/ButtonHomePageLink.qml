import QtQuick 1.1
import Components.Text 1.0
import BtExperience 1.0


SvgImage {
    id: button
    property string text: ""
    property string textSystem: ""
    property string textOption: ""
    property string textMultimedia: ""
    property url icon: ""
    property url iconPressed: ""
    property url sourcePressed: ""

    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: button.clicked()
    }

    SvgImage {
        id: imageIcon
        source: button.icon
        anchors.horizontalCenter: text.horizontalCenter
        anchors.centerIn: parent
    }

    UbuntuMediumText {
        id: text
        color: global.guiSettings.skin === GuiSettings.Clear ? "#434343" :
                                                              "#FFFFFF"
        text: button.text
        anchors.centerIn: imageIcon
        anchors.verticalCenterOffset: width / 1000 * 1000
        font.pixelSize: 13
    }

    UbuntuMediumText {
        id: textSystem
        color: global.guiSettings.skin === GuiSettings.Clear ? "#434343" :
                                                              "#FFFFFF"
        text: button.textSystem
        anchors.centerIn: imageIcon
        anchors.verticalCenterOffset: width / 1000 * 750
        font.pixelSize: 13
    }

    UbuntuMediumText {
        id: textOption
        color: global.guiSettings.skin === GuiSettings.Clear ? "#434343" :
                                                               "#FFFFFF"
        text: button.textOption
        anchors.centerIn: imageIcon
        anchors.verticalCenterOffset: width / 1000 * -850
        font.pixelSize: 13
    }

    UbuntuMediumText {
        id: textMultimedia
        color: global.guiSettings.skin === GuiSettings.Clear ? "#434343" :
                                                               "#FFFFFF"
        text: button.textMultimedia
        anchors.centerIn: imageIcon
         anchors.verticalCenterOffset: width / 1000 * -565
        font.pixelSize: 13
    }

    states: State {
        name: "pressed"
        when: mouseArea.pressed

        PropertyChanges {
            target: button
            source: sourcePressed
        }

        PropertyChanges {
            target: text
            color: global.guiSettings.skin === GuiSettings.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }

        PropertyChanges {
            target: textSystem
            color: global.guiSettings.skin === GuiSettings.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }

        PropertyChanges {
            target: textOption
            color: global.guiSettings.skin === GuiSettings.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }

        PropertyChanges {
            target: textMultimedia
            color: global.guiSettings.skin === GuiSettings.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }

        PropertyChanges {
            target: imageIcon
            source: iconPressed
        }
    }
}
