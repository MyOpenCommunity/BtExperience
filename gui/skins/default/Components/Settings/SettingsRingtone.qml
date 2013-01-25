import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0


MenuColumn {
    id: column

    property int type

    QtObject {
        id: privateProps
        property variant ringtones: global.ringtoneManager.ringtoneList()
        property int currentIndex: 0
    }


    ControlLeftRightWithTitle {
        title: qsTr("Ringtones")
        text: privateProps.ringtones[privateProps.currentIndex].replace(/^.*[\\\/]/, '').split(".").shift() // some JS magic to extract file name
        onLeftClicked: {
            privateProps.currentIndex = (privateProps.currentIndex - 1 + privateProps.ringtones.length) % privateProps.ringtones.length
            global.ringtoneManager.setRingtoneFromFilename(type, privateProps.ringtones[privateProps.currentIndex])
            previewTimer.restart()
        }
        onRightClicked: {
            privateProps.currentIndex = (privateProps.currentIndex + 1) % privateProps.ringtones.length
            global.ringtoneManager.setRingtoneFromFilename(type, privateProps.ringtones[privateProps.currentIndex])
            previewTimer.restart()
        }
    }

    Timer {
        id: previewTimer
        interval: 1000
        onTriggered: global.ringtoneManager.playRingtone(privateProps.ringtones[privateProps.currentIndex], AudioState.Ringtone)
    }

    Component.onCompleted: {
        // search the current active ringtone for type
        var currentString = global.ringtoneManager.ringtoneFromType(type)
        for (var i = 0; i < privateProps.ringtones.length; ++i) {
            if (currentString === privateProps.ringtones[i]) {
                privateProps.currentIndex = i
                break
            }
        }
        previewTimer.start()
    }
}
