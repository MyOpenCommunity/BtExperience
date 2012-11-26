import QtQuick 1.1
import Components.Text 1.0
import "../js/EventManager.js" as EventManager
import "../js/navigation.js" as Navigation


Item {
    id: control

    Rectangle {
        id: bottomBg
        opacity: 0.8
        color: "#5A5A5A"
        anchors.fill: parent
    }

    UbuntuLightText {
        id: label
        text: qsTr("Save scenario recording?")
        font.pixelSize: 14
        color: "white"
        anchors {
            verticalCenter: bottomBg.verticalCenter
            right: okButton.left
            rightMargin: bottomBg.width / 100 * 1.00
        }
    }

    ButtonThreeStates {
        id: okButton

        defaultImage: "../images/common/btn_99x35.svg"
        pressedImage: "../images/common/btn_99x35_P.svg"
        selectedImage: "../images/common/btn_99x35_S.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        text: qsTr("OK")
        font.pixelSize: 14
        anchors {
            verticalCenter: bottomBg.verticalCenter
            right: bottomBg.right
            rightMargin: bottomBg.width / 100 * 1.00
        }
        onClicked: {
            if (EventManager.eventManager.scenarioRecording)
                EventManager.eventManager.scenarioRecorder.stopProgramming()
            else
                console.log("Trying to finalize a scenario recording, but no scenario module is in edit mode")
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 400 }
    }
}
