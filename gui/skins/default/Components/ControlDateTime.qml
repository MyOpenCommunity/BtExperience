import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Item {
    id: control

    property variant itemObject: undefined
    property int leftColumnValue: itemObject === undefined ? 0 : mode === 0 ? itemObject.hours : itemObject.days
    property int centerColumnValue: itemObject === undefined ? 0 : mode === 0 ? itemObject.minutes : itemObject.months
    property int rightColumnValue:  privateProps.getRightValue()
    property string separator: ":"
    property bool twoFields: false // if true right disappears
    property int mode: 0 // 0 - hms, 1 - dmy
    property bool enabled: true

    opacity: enabled ? 1 : 0.5

    width: loader.width
    height: loader.height

    QtObject {
        id: privateProps

        function getRightValue() {
            if (itemObject === undefined || twoFields === true) {
                return 0
            }
            else {
                return mode === 0 ? itemObject.seconds : itemObject.years
            }
        }
    }

    function formatNumberLength(num, length) {
        var r = "" + num;
        while (r.length < length) {
            r = "0" + r;
        }
        return r;
    }

    Loader {
        id: loader
        sourceComponent: twoFields ? twoFieldsComponent : threeFieldsComponent
    }

    MouseArea {
        anchors.fill: parent
        z: 10 // to be upper of smallbuttons
        visible: !control.enabled
    }

    Component {
        id: twoFieldsComponent
        ControlDoubleSpin {
            separator: ":"
            onLeftPlusClicked: itemObject.hours += 1
            onRightPlusClicked: itemObject.minutes += 1
            onLeftMinusClicked: itemObject.hours -= 1
            onRightMinusClicked: itemObject.minutes -= 1
            leftText: formatNumberLength(leftColumnValue, 2)
            rightText: formatNumberLength(centerColumnValue, 2)
        }
    }

    Component {
        id: threeFieldsComponent

        Item {
            width: buttonLeftPlus.width + buttonCenterPlus.width + buttonRightPlus.width
            height: buttonLeftPlus.height + bg.height + buttonLeftMinus.height

            ButtonImageThreeStates {
                id: buttonLeftPlus
                z: 1
                anchors {
                    top: parent.top
                    left: parent.left
                }

                defaultImageBg: "../images/common/btn_66x35.svg"
                pressedImageBg: "../images/common/btn_66x35_P.svg"
                shadowImage: "../images/common/btn_shadow_66x35.svg"
                defaultImage: "../images/common/ico_piu.svg"
                pressedImage: "../images/common/ico_piu_P.svg"
                status: 0
                repetitionOnHold: true
                onClicked: mode === 0 ? itemObject.hours += 1 : itemObject.days += 1
            }

            ButtonImageThreeStates {
                id: buttonCenterPlus
                z: 1
                anchors {
                    top: parent.top
                    left: buttonLeftPlus.right
                }

                defaultImageBg: "../images/common/btn_66x35.svg"
                pressedImageBg: "../images/common/btn_66x35_P.svg"
                shadowImage: "../images/common/btn_shadow_66x35.svg"
                defaultImage: "../images/common/ico_piu.svg"
                pressedImage: "../images/common/ico_piu_P.svg"
                status: 0
                repetitionOnHold: true
                onClicked: mode === 0 ? itemObject.minutes += 1 : itemObject.months += 1
            }

            ButtonImageThreeStates {
                id: buttonRightPlus
                z: 1
                anchors {
                    top: parent.top
                    left: buttonCenterPlus.right
                }

                defaultImageBg: "../images/common/btn_66x35.svg"
                pressedImageBg: "../images/common/btn_66x35_P.svg"
                shadowImage: "../images/common/btn_shadow_66x35.svg"
                defaultImage: "../images/common/ico_piu.svg"
                pressedImage: "../images/common/ico_piu_P.svg"
                status: 0
                repetitionOnHold: true
                onClicked: mode === 0 ? itemObject.seconds += 1 : itemObject.years += 1
            }

            SvgImage {
                id: bg
                source: "../images/common/bg_datetime.svg"
                anchors {
                    top: buttonLeftPlus.bottom
                    left: parent.left
                    right: buttonRightPlus.right
                }
            }

            ButtonImageThreeStates {
                id: buttonLeftMinus
                z: 1
                anchors {
                    top: bg.bottom
                    left: parent.left
                }

                defaultImageBg: "../images/common/btn_66x35.svg"
                pressedImageBg: "../images/common/btn_66x35_P.svg"
                shadowImage: "../images/common/btn_shadow_66x35.svg"
                defaultImage: "../images/common/ico_meno.svg"
                pressedImage: "../images/common/ico_meno_P.svg"
                status: 0
                repetitionOnHold: true
                onClicked: mode === 0 ? itemObject.hours -= 1 : itemObject.days -= 1
            }

            ButtonImageThreeStates {
                id: buttonCenterMinus
                z: 1
                anchors {
                    top: bg.bottom
                    left: buttonLeftMinus.right
                }

                defaultImageBg: "../images/common/btn_66x35.svg"
                pressedImageBg: "../images/common/btn_66x35_P.svg"
                shadowImage: "../images/common/btn_shadow_66x35.svg"
                defaultImage: "../images/common/ico_meno.svg"
                pressedImage: "../images/common/ico_meno_P.svg"
                status: 0
                repetitionOnHold: true
                onClicked: mode === 0 ? itemObject.minutes -= 1 : itemObject.months -= 1
            }

            ButtonImageThreeStates {
                id: buttonRightMinus
                z: 1
                anchors {
                    top: bg.bottom
                    left: buttonCenterMinus.right
                }

                defaultImageBg: "../images/common/btn_66x35.svg"
                pressedImageBg: "../images/common/btn_66x35_P.svg"
                shadowImage: "../images/common/btn_shadow_66x35.svg"
                defaultImage: "../images/common/ico_meno.svg"
                pressedImage: "../images/common/ico_meno_P.svg"
                status: 0
                repetitionOnHold: true
                onClicked: mode === 0 ? itemObject.seconds -= 1 : itemObject.years -= 1
            }

            UbuntuLightText {
                id: leftText

                text: formatNumberLength(leftColumnValue, 2)
                color: "#5b5b5b"
                font.pixelSize: 22
                anchors.horizontalCenter: buttonLeftMinus.horizontalCenter
                anchors.verticalCenter: bg.verticalCenter
            }

            UbuntuLightText {
                id: separator1
                text: control.separator
                color: "#5b5b5b"
                font.pixelSize: 22
                anchors.verticalCenter: bg.verticalCenter
                anchors.left: buttonLeftMinus.right
                anchors.leftMargin: - paintedWidth / 2
            }


            UbuntuLightText {
                id: centerText

                text: formatNumberLength(centerColumnValue, 2) + (mode === 1 ? "" : "'")
                color: "#5b5b5b"
                font.pixelSize: 22
                anchors.horizontalCenter: buttonCenterMinus.horizontalCenter
                anchors.verticalCenter: bg.verticalCenter
            }

            UbuntuLightText {
                id: separator2

                color: "#5b5b5b"
                text: control.separator
                font.pixelSize: 22
                anchors.verticalCenter: bg.verticalCenter
                anchors.left: buttonCenterMinus.right
                anchors.leftMargin: - paintedWidth / 2
            }

            UbuntuLightText {
                id: rightText

                text: formatNumberLength(rightColumnValue, 2) + (mode === 1 ? "" : "\"")
                color: "#5b5b5b"
                font.pixelSize: 22
                anchors.horizontalCenter: buttonRightMinus.horizontalCenter
                anchors.verticalCenter: bg.verticalCenter
            }

        }
    }

}
