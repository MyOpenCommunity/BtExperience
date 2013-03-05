import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import BtObjects 1.0

import "../../js/formatting.js" as Formatting

MenuColumn {
    id: column

    property int view_decimals: 3
    property int int_decimals: Math.pow(10, view_decimals)

    Item {
        id: controls
        width: bg1.width
        height: bg1.height
        SvgImage {
            id: bg1
            source: "../../images/termo/comando_data-ora/bg_comando_data-ora.svg"
        }

        UbuntuLightText {
            id: labelThreshold1
            color: "black"
            text: qsTr("threshold 1") + " ("  + dataModel.currentUnit + ")"
            font.pixelSize: 15
            anchors {
                top: parent.top
                topMargin: parent.height / 100 * 2
                left: parent.left
                leftMargin: parent.width / 100 * 4
            }
        }

        ControlDoubleSpin {
            id: spinThreshold1
            property int intPart: Math.floor(dataModel.thresholds[0])
            property int decPart: (dataModel.thresholds[0] - Math.floor(dataModel.thresholds[0])) * int_decimals

            leftText: Formatting.padNumber(intPart, 2)
            rightText: Formatting.padNumber(decPart, view_decimals)
            onLeftMinusClicked: {
                if (intPart > 0)
                    intPart -= 1
                else
                    intPart = 64
            }
            onLeftPlusClicked: {
                if (intPart < 64)
                    intPart += 1
                else
                    intPart = 0
            }
            onRightMinusClicked: {
                if (decPart > 0)
                    decPart -= 1
                else {
                    decPart = int_decimals - 1
                    spinThreshold1.leftMinusClicked()
                }
            }
            onRightPlusClicked: {
                if (decPart < int_decimals - 1) {
                    decPart += 1
                }
                else {
                    decPart = 0
                    spinThreshold1.leftPlusClicked()
                }
            }
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelThreshold1.bottom
                topMargin: parent.height / 100 * 2
            }
        }

        UbuntuLightText {
            id: labelThreshold2
            color: "black"
            text: qsTr("threshold 2") + " ("  + dataModel.currentUnit + ")"
            font.pixelSize: 15
            anchors {
                top: spinThreshold1.bottom
                topMargin: parent.height / 100 * 2
                left: parent.left
                leftMargin: parent.width / 100 * 4
            }
        }

        ControlDoubleSpin {
            id: spinThreshold2
            property int intPart: Math.floor(dataModel.thresholds[1])
            property int decPart: (dataModel.thresholds[1] - Math.floor(dataModel.thresholds[1])) * int_decimals

            leftText: Formatting.padNumber(intPart, 2)
            rightText: Formatting.padNumber(decPart, view_decimals)
            onLeftMinusClicked: {
                if (intPart > 0)
                    intPart -= 1
                else
                    intPart = 64
            }
            onLeftPlusClicked: {
                if (intPart < 64)
                    intPart += 1
                else
                    intPart = 0
            }
            onRightMinusClicked: {
                if (decPart > 0)
                    decPart -= 1
                else {
                    decPart = int_decimals - 1
                    spinThreshold2.leftMinusClicked()
                }
            }
            onRightPlusClicked: {
                if (decPart < int_decimals - 1) {
                    decPart += 1
                }
                else {
                    decPart = 0
                    spinThreshold2.leftPlusClicked()
                }
            }

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelThreshold2.bottom
                topMargin: parent.height / 100 * 2
            }
        }
    }

    ButtonOkCancel {
        anchors {
            top: controls.bottom
            left: parent.left
            right: parent.right
        }

        onCancelClicked: column.closeColumn()
        onOkClicked: {
            dataModel.thresholds = [
                        spinThreshold1.intPart + spinThreshold1.decPart / int_decimals,
                        spinThreshold2.intPart + spinThreshold2.decPart / int_decimals
                    ]

            column.closeColumn()
        }
    }

}
