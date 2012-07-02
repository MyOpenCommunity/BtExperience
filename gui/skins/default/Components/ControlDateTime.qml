import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../js/datetime.js" as DateTime


Item {
    id: control

    property variant itemObject: undefined
    property int leftColumnValue: itemObject === undefined ? 0 : mode === 0 ? itemObject.hours : itemObject.days
    property int centerColumnValue: itemObject === undefined ? 0 : mode === 0 ? itemObject.minutes : itemObject.months
    property int rightColumnValue: itemObject === undefined ? 0 : mode === 0 ? itemObject.seconds : itemObject.years
    property string separator: ":"
    property bool twoFields: false // if true right disappears
    property int mode: 0 // 0 - hms, 1 - dmy
    property bool enabled: true

    width: twoFields ? buttonLeftPlus.width + buttonCenterPlus.width :
                       buttonLeftPlus.width + buttonCenterPlus.width + buttonRightPlus.width
    height: buttonLeftPlus.height + bg.height + buttonLeftMinus.height
    opacity: enabled ? 1 : 0.5

    QtObject {
        id: privateProps
        property int textBottomMargin: 1
        property int separatorOffset: -3
    }

    function formatNumberLength(num, length) {
        var r = "" + num;
        while (r.length < length) {
            r = "0" + r;
        }
        return r;
    }

    MouseArea {
        anchors.fill: parent
        z: 10 // to be upper of smallbuttons
        visible: !control.enabled
    }

    ButtonImageThreeStates {
        id: buttonLeftPlus
        z: 1
        anchors {
            top: parent.top
            left: parent.left
        }

        defaultImageBg: twoFields ? "../images/common/btn_99x35.svg" : "../images/common/btn_66x35.svg"
        pressedImageBg: twoFields ? "../images/common/btn_99x35_P.svg" : "../images/common/btn_66x35_P.svg"
        shadowImage: twoFields ? "../images/common/btn_shadow_99x35.svg" : "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        status: 0
        timerEnabled: true
        onClicked: mode === 0 ? itemObject.hours += 1 : itemObject.days += 1
    }

    ButtonImageThreeStates {
        id: buttonCenterPlus
        z: 1
        anchors {
            top: parent.top
            left: buttonLeftPlus.right
        }

        defaultImageBg: twoFields ? "../images/common/btn_99x35.svg" : "../images/common/btn_66x35.svg"
        pressedImageBg: twoFields ? "../images/common/btn_99x35_P.svg" : "../images/common/btn_66x35_P.svg"
        shadowImage: twoFields ? "../images/common/btn_shadow_99x35.svg" : "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        status: 0
        timerEnabled: true
        onClicked: mode === 0 ? itemObject.minutes += 1 : itemObject.months += 1
    }

    ButtonImageThreeStates {
        id: buttonRightPlus
        z: 1
        anchors {
            top: parent.top
            left: buttonCenterPlus.right
        }
        visible: !control.twoFields

        defaultImageBg: "../images/common/btn_66x35.svg"
        pressedImageBg: "../images/common/btn_66x35_P.svg"
        shadowImage: "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_piu.svg"
        pressedImage: "../images/common/ico_piu_P.svg"
        status: 0
        timerEnabled: true
        onClicked: mode === 0 ? itemObject.seconds += 1 : itemObject.years += 1
    }

    SvgImage {
        id: bg
        source: "../images/common/date_panel_inner_background.svg"
        height: 32
        anchors {
            top: buttonLeftPlus.bottom
            left: parent.left
            right: control.twoFields ? buttonCenterPlus.right : buttonRightPlus.right
        }
    }

    ButtonImageThreeStates {
        id: buttonLeftMinus
        z: 1
        anchors {
            top: bg.bottom
            left: parent.left
        }

        defaultImageBg: twoFields ? "../images/common/btn_99x35.svg" : "../images/common/btn_66x35.svg"
        pressedImageBg: twoFields ? "../images/common/btn_99x35_P.svg" : "../images/common/btn_66x35_P.svg"
        shadowImage: twoFields ? "../images/common/btn_shadow_99x35.svg" : "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        status: 0
        timerEnabled: true
        onClicked: mode === 0 ? itemObject.hours -= 1 : itemObject.days -= 1
    }

    ButtonImageThreeStates {
        id: buttonCenterMinus
        z: 1
        anchors {
            top: bg.bottom
            left: buttonLeftMinus.right
        }

        defaultImageBg: twoFields ? "../images/common/btn_99x35.svg" : "../images/common/btn_66x35.svg"
        pressedImageBg: twoFields ? "../images/common/btn_99x35_P.svg" : "../images/common/btn_66x35_P.svg"
        shadowImage: twoFields ? "../images/common/btn_shadow_99x35.svg" : "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        status: 0
        timerEnabled: true
        onClicked: mode === 0 ? itemObject.minutes -= 1 : itemObject.months -= 1
    }

    ButtonImageThreeStates {
        id: buttonRightMinus
        z: 1
        anchors {
            top: bg.bottom
            left: buttonCenterMinus.right
        }
        visible: !control.twoFields

        defaultImageBg: "../images/common/btn_66x35.svg"
        pressedImageBg: "../images/common/btn_66x35_P.svg"
        shadowImage: "../images/common/btn_shadow_66x35.svg"
        defaultImage: "../images/common/ico_meno.svg"
        pressedImage: "../images/common/ico_meno_P.svg"
        status: 0
        timerEnabled: true
        onClicked: mode === 0 ? itemObject.seconds -= 1 : itemObject.years -= 1
    }

    UbuntuLightText {
        id: leftText

        text: formatNumberLength(leftColumnValue, 2)
        color: "#5b5b5b"
        font.pixelSize: 22
        anchors.horizontalCenter: buttonLeftMinus.horizontalCenter
        anchors.bottom: buttonLeftMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
    }

    UbuntuLightText {
        id: separator1

        text: control.separator
        color: "#5b5b5b"
        font.pixelSize: 22
        anchors.bottom: buttonCenterMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
        anchors.left: buttonCenterMinus.left
        anchors.leftMargin: privateProps.separatorOffset
    }


    UbuntuLightText {
        id: centerText

        text: formatNumberLength(centerColumnValue, 2) + ((twoFields || mode === 1) ? "" : "'")
        color: "#5b5b5b"
        font.pixelSize: 22
        anchors.horizontalCenter: buttonCenterMinus.horizontalCenter
        anchors.bottom: buttonCenterMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
    }

    UbuntuLightText {
        id: separator2

        color: "#5b5b5b"
        text: control.separator
        font.pixelSize: 22
        visible: !twoFields
        anchors.bottom: buttonCenterMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
        anchors.right: buttonCenterMinus.right
        anchors.rightMargin: privateProps.separatorOffset
    }

    UbuntuLightText {
        id: rightText

        text: formatNumberLength(rightColumnValue, 2) + ((mode === 1) ? "" : "\"")
        color: "#5b5b5b"
        font.pixelSize: 22
        visible: !twoFields
        anchors.horizontalCenter: buttonRightMinus.horizontalCenter
        anchors.bottom: buttonRightMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
    }
}
