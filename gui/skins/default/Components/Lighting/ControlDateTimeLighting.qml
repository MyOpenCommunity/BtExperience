import QtQuick 1.1
import Components 1.0

Item {
    id: control

    property int leftColumnValue: 1
    property int centerColumnValue: 1
    property int rightColumnValue: 13
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

    function leftPlusClicked() {
        if(control.mode === 0) {
            // hour
            if(leftColumnValue >= 23)
                return
        }
        else {
            // day
            // TODO not all months have 31 days...
            if(leftColumnValue >= 31)
                return
        }
        leftColumnValue += 1
    }

    function centerPlusClicked() {
        if(control.mode === 0) {
            // min
            if(centerColumnValue >= 59)
                return
        }
        else {
            // month
            if(centerColumnValue >= 12)
                return
        }
        centerColumnValue += 1
    }

    function rightPlusClicked() {
        if(control.mode === 0) {
            // sec
            if(centerColumnValue >= 59)
                return
        }
        else {
            // year
            if(rightColumnValue >= 99)
                rightColumnValue = -1 // rotate to zero
        }
        rightColumnValue += 1
    }

    function leftMinusClicked() {
        if(control.mode === 0) {
            // hour
            if(leftColumnValue <= 0)
                return
        }
        else {
            // day
            if(leftColumnValue <= 1)
                return
        }
        leftColumnValue -= 1
    }

    function centerMinusClicked() {
        if(control.mode === 0) {
            // minutes
            if(centerColumnValue <= 0)
                return
        }
        else {
            // month
            if(centerColumnValue <= 1)
                return
        }
        centerColumnValue -= 1
    }

    function rightMinusClicked() {
        if(control.mode === 0) {
            // sec
            if(centerColumnValue <= 0)
                return
        }
        else {
            // year
            if(rightColumnValue <= 0)
                rightColumnValue = 100 // rotate to 99
        }
        rightColumnValue -= 1
    }

    function formatNumberLength(num, length) {
        var r = "" + num;
        while (r.length < length) {
            r = "0" + r;
        }
        return r;
    }

    SmallButton {
        id: buttonLeftPlus
        z: 1
        inputAllowed: control.enabled
        anchors {
            top: parent.top
            left: parent.left
        }

        SvgImage {
            anchors.centerIn: parent
            source: "../../images/common/symbol_plus.svg"
        }

        onButtonClicked: leftPlusClicked()
        onButtonPressed: leftPlusTimer.running = true
        onButtonReleased: leftPlusTimer.running = false

        Timer {
            id: leftPlusTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: leftPlusClicked()
        }
    }

    SmallButton {
        id: buttonCenterPlus
        z: 1
        inputAllowed: control.enabled
        anchors {
            top: parent.top
            left: buttonLeftPlus.right
        }

        SvgImage {
            anchors.centerIn: parent
            source: "../../images/common/symbol_plus.svg"
        }

        onButtonClicked: centerPlusClicked()
        onButtonPressed: centerPlusTimer.running = true
        onButtonReleased: centerPlusTimer.running = false

        Timer {
            id: centerPlusTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: centerPlusClicked()
        }
    }

    SmallButton {
        id: buttonRightPlus
        z: 1
        inputAllowed: control.enabled
        anchors {
            top: parent.top
            left: buttonCenterPlus.right
        }
        visible: !control.twoFields

        SvgImage {
            anchors.centerIn: parent
            source: "../../images/common/symbol_plus.svg"
        }

        onButtonClicked: rightPlusClicked()
        onButtonPressed: rightPlusTimer.running = true
        onButtonReleased: rightPlusTimer.running = false

        Timer {
            id: rightPlusTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: rightPlusClicked()
        }
    }

    SvgImage {
        id: bg
        source: "../../images/common/date_panel_inner_background.svg"
        height: 32
        anchors {
            top: buttonLeftPlus.bottom
            left: parent.left
            right: control.twoFields ? buttonCenterPlus.right : buttonRightPlus.right
        }
    }

    SmallButton {
        id: buttonLeftMinus
        z: 1
        inputAllowed: control.enabled
        anchors {
            top: bg.bottom
            left: parent.left
        }

        SvgImage {
            anchors.centerIn: parent
            source: "../../images/common/symbol_minus.svg"
        }

        onButtonClicked: leftMinusClicked()
        onButtonPressed: leftMinusTimer.running = true
        onButtonReleased: leftMinusTimer.running = false

        Timer {
            id: leftMinusTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: leftMinusClicked()
        }
    }

    SmallButton {
        id: buttonCenterMinus
        z: 1
        inputAllowed: control.enabled
        anchors {
            top: bg.bottom
            left: buttonLeftMinus.right
        }

        SvgImage {
            anchors.centerIn: parent
            source: "../../images/common/symbol_minus.svg"
        }

        onButtonClicked: centerMinusClicked()
        onButtonPressed: centerMinusTimer.running = true
        onButtonReleased: centerMinusTimer.running = false

        Timer {
            id: centerMinusTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: centerMinusClicked()
        }
    }

    SmallButton {
        id: buttonRightMinus
        z: 1
        inputAllowed: control.enabled
        anchors {
            top: bg.bottom
            left: buttonCenterMinus.right
        }
        visible: !control.twoFields

        SvgImage {
            anchors.centerIn: parent
            source: "../../images/common/symbol_minus.svg"
        }

        onButtonClicked: rightMinusClicked()
        onButtonPressed: rightMinusTimer.running = true
        onButtonReleased: rightMinusTimer.running = false

        Timer {
            id: rightMinusTimer
            interval: 500
            running: false
            repeat: true
            onTriggered: rightMinusClicked()
        }
    }

    Text {
        id: leftText

        text: formatNumberLength(leftColumnValue, 2)
        color: "#5b5b5b"
        font.pointSize: 18
        font.bold: true
        anchors.horizontalCenter: buttonLeftMinus.horizontalCenter
        anchors.bottom: buttonLeftMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
    }

    Text {
        id: separator1

        text: control.separator
        color: "#5b5b5b"
        font.pointSize: 18
        font.bold: true
        anchors.bottom: buttonCenterMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
        anchors.left: buttonCenterMinus.left
        anchors.leftMargin: privateProps.separatorOffset
    }


    Text {
        id: centerText

        text: formatNumberLength(centerColumnValue, 2)
        color: "#5b5b5b"
        font.pointSize: 18
        font.bold: true
        anchors.horizontalCenter: buttonCenterMinus.horizontalCenter
        anchors.bottom: buttonCenterMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
    }

    Text {
        id: separator2

        color: "#5b5b5b"
        text: control.separator
        font.bold: true
        font.pointSize: 18
        visible: !twoFields
        anchors.bottom: buttonCenterMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
        anchors.right: buttonCenterMinus.right
        anchors.rightMargin: privateProps.separatorOffset
    }

    Text {
        id: rightText

        text: formatNumberLength(rightColumnValue, 2)
        color: "#5b5b5b"
        font.pointSize: 18
        font.bold: true
        visible: !twoFields
        anchors.horizontalCenter: buttonRightMinus.horizontalCenter
        anchors.bottom: buttonRightMinus.top
        anchors.bottomMargin: privateProps.textBottomMargin
    }
}
