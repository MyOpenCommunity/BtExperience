import QtQuick 1.1
import "Stack.js" as Stack
import BtObjects 1.0

MenuElement {
    width: 212
    height: 164

    onChildDestroyed: privateProps.currentIndex = -1

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdHardwareSettings}]
    }

    QtObject {
        id: privateProps
        property variant model: objectModel.getObject(0)
    }

    Connections {
        target: privateProps.model
        onCurrentScenarioChanged: privateProps.model.brightness()
    }

    Image {
        x: 0
        y: 0
        width: 212
        height: 331
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: -167
        source: "images/common/dimmer_bg.png"
        anchors.fill: parent

        Text {
            id: textBrightness
            x: 72
            y: 7
            text: qsTr("brightness adjustment")
            anchors.horizontalCenterOffset: 1
            color: "#444546"
            wrapMode: "WordWrap"
            font.pixelSize: 13
            anchors.top: onOff.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: textPercentage
            text: dataModel.percentage + "%"
            font.bold: true
            color: "#444546"
            anchors.top: textBrightness.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Image {
            id: brightnessReg
            x: 2
            y: 56
            source: "images/common/dimmer_reg_bg.png"
            width: 212
            height: 108
            anchors.horizontalCenterOffset: 2
            anchors.top: textPercentage.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: barPercentage
                x: 0
                y: 0
                source: "images/common/dimmer_reg.png"
                anchors.left: parent.left
                width: parent.width / 100 * dataModel.sendCommand
                height: 59
                anchors.leftMargin: 0
                Behavior on width {
                    NumberAnimation { duration: 100; }
                }
            }
        }

        ButtonMinusPlus {
            id: brightnessMinusPlus
            x: 2
            y: 115
            height: 49
            anchors.horizontalCenterOffset: 0
            anchors.topMargin: -49
            anchors.top: brightnessReg.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onPlusClicked: {
                Settings.setBrightness +=25
                dataModel.percentage += 5
                if (dataModel.percentage > 100)
                    dataModel.percentage = 100
            }
            onMinusClicked: {
                dataModel.percentage -= 5
                if (dataModel.percentage < 0)
                    dataModel.percentage = 0
            }
        }
    }
    Image {
        x: 0
        y: 164
        width: 212
        height: 0
        anchors.topMargin: 164
        anchors.bottomMargin: 0
        source: "images/common/dimmer_bg.png"
        anchors.fill: parent

        Text {
            id: textContrast
            x: 72
            y: 7
            text: qsTr("contrast")
            anchors.horizontalCenterOffset: 1
            color: "#444546"
            wrapMode: "WordWrap"
            font.pixelSize: 13
            anchors.top: onOff.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: textPercentageContrast
            text: dataModel.percentage + "%"
            font.bold: true
            color: "#444546"
            anchors.top: textBrightness.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Image {
            id: contrastReg
            x: 2
            y: 56
            source: "images/common/dimmer_reg_bg.png"
            width: 212
            height: 108
            anchors.horizontalCenterOffset: 2
            anchors.top: textPercentage.bottom
            anchors.topMargin: setBrightness
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: barPercentageContrast
                x: 0
                y: 0
                source: "images/common/dimmer_reg.png"
                anchors.left: parent.left
                width: parent.width / 100 * dataModel.sendCommand
                height: 59
                anchors.leftMargin: 0
                Behavior on width {
                    NumberAnimation { duration: 100; }
                }
            }
        }

        ButtonMinusPlus {
            id: contrastMinusPlus
            x: 2
            y: 115
            height: 49
            anchors.horizontalCenterOffset: 0
            anchors.topMargin: -49
            anchors.top: brightnessReg.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onPlusClicked: {
                Settings.setBrightness +=25
                dataModel.percentage += 5
                if (dataModel.percentage > 100)
                    dataModel.percentage = 100
            }
            onMinusClicked: {
                dataModel.percentage -= 5
                if (dataModel.percentage < 0)
                    dataModel.percentage = 0
            }
        }
    }
}
