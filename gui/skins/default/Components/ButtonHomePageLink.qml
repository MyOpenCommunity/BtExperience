import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components.Text 1.0


SvgImage {
    id: button

    property string text: ""
    property string textSystem: ""
    property string textOption: ""
    property string textMultimedia: ""
    property url icon: ""
    property url iconPressed: ""
    property url sourcePressed: ""
    property bool enabled: true

    signal clicked

    BeepingMouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: button.clicked()
    }

    Rectangle {
        z: 1
        anchors.fill: parent
        color: "silver"
        opacity: 0.6
        visible: button.enabled === false
        MouseArea {
            anchors.fill: parent
        }
    }

    SvgImage {
        id: imageIcon
        source: button.icon
        anchors.horizontalCenter: text.horizontalCenter
        anchors.centerIn: parent
    }

    UbuntuMediumText {
        id: text
        color: homeProperties.skin === HomeProperties.Clear ? "#434343" :
                                                              "#FFFFFF"
        text: button.text
        anchors.centerIn: imageIcon
        anchors.verticalCenterOffset: width / 1000 * 1000
        font.pixelSize: 15
    }

    UbuntuMediumText {
        id: textSystem
        color: homeProperties.skin === HomeProperties.Clear ? "#434343" :
                                                              "#FFFFFF"
        text: button.textSystem
        anchors.centerIn: imageIcon
        anchors.verticalCenterOffset: width / 1000 * 750
        font.pixelSize: 15
    }

    UbuntuMediumText {
        id: textOption
        color: homeProperties.skin === HomeProperties.Clear ? "#434343" :
                                                               "#FFFFFF"
        text: button.textOption
        anchors.centerIn: imageIcon
        anchors.verticalCenterOffset: width / 1000 * -850
        font.pixelSize: 15
    }

    UbuntuMediumText {
        id: textMultimedia
        color: homeProperties.skin === HomeProperties.Clear ? "#434343" :
                                                               "#FFFFFF"
        text: button.textMultimedia
        anchors.centerIn: imageIcon
        anchors.verticalCenterOffset: width / 1000 * -565
        font.pixelSize: 15
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
            color: homeProperties.skin === HomeProperties.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }

        PropertyChanges {
            target: textSystem
            color: homeProperties.skin === HomeProperties.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }

        PropertyChanges {
            target: textOption
            color: homeProperties.skin === HomeProperties.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }

        PropertyChanges {
            target: textMultimedia
            color: homeProperties.skin === HomeProperties.Clear ? "#FFFFFF" :
                                                                   "#434343"
        }

        PropertyChanges {
            target: imageIcon
            source: iconPressed
        }
    }
}
