import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "../../js/datetime.js" as DateTime


Column {
    id: control

    property int leftColumnValue: 2
    property int centerColumnValue: 3
    property int rightColumnValue: 8
    property string leftLabel: "left"
    property string centerLabel: "very center"
    property string rightLabel: "sh"
    property string separator: ":"
    property bool twoFields: false // if true right disappears


    function leftPlusClicked() {
        if (control.twoFields) {
            // hour
            if (leftColumnValue >= 23)
                return
        }
        else {
            // day
            if (leftColumnValue >= DateTime.daysInMonth(centerColumnValue,"20"+rightColumnValue))
                return
        }
        leftColumnValue += 1
    }

    function centerPlusClicked() {
        if (control.twoFields) {
            // min
            if (centerColumnValue >= 59)
                return
        }
        else {
            // month
            if (centerColumnValue >= 12)
                return
        }
        centerColumnValue += 1
    }

    function rightPlusClicked() {
        if (rightColumnValue >= 99)
            rightColumnValue = -1
        rightColumnValue += 1
    }

    function leftMinusClicked() {
        if (control.twoFields) {
            // hour
            if (leftColumnValue <= 0)
                return
        }
        else {
            // day
            if (leftColumnValue <= 1)
                return
        }
        leftColumnValue -= 1
    }

    function centerMinusClicked() {
        if (control.twoFields) {
            // minutes
            if (centerColumnValue <= 0)
                return
        }
        else {
            // month
            if (centerColumnValue <= 1)
                return
        }
        centerColumnValue -= 1
    }

    function rightMinusClicked() {
        if (rightColumnValue <= 0)
            rightColumnValue = 100
        rightColumnValue -= 1
    }

    function formatNumberLength(num, length) {
        var r = "" + num;
        while (r.length < length) {
            r = "0" + r;
        }
        return r;
    }


    Row {
        id: buttons

        z: 1
        DateTimeButton {
            text: "+"
            onButtonClicked: leftPlusClicked()
        }

        DateTimeButton {
            text: "+"
            onButtonClicked: centerPlusClicked()
        }

        DateTimeButton {
            text: "+"
            onButtonClicked: rightPlusClicked()
            visible: !twoFields
        }
    }

    SvgImage {
        source: "../../images/common/date_panel_inner_background.svg"
        width: buttons.width

        UbuntuLightText {
            id: leftText
            x: 27
            text: formatNumberLength(leftColumnValue, 2)
            color: "#5b5b5b"
            font.pixelSize: 18
            font.bold: true
        }
        UbuntuLightText {
            text: control.leftLabel
            y: 30
            anchors.horizontalCenter: leftText.horizontalCenter
            color: "#5b5b5b"
        }

        UbuntuLightText {
            id: separator1
            x: 79
            y: 10
            text: control.separator
            color: "#5b5b5b"
            font.pixelSize: 18
            font.bold: true
        }


        UbuntuLightText {
            id: centerText
            x: 109
            text: formatNumberLength(centerColumnValue, 2)
            color: "#5b5b5b"
            font.pixelSize: 18
            font.bold: true
        }
        UbuntuLightText {
            y: 30
            text: control.centerLabel
            anchors.horizontalCenter: centerText.horizontalCenter
            color: "#5b5b5b"
        }

        UbuntuLightText {
            id: separator2
            x: 162
            y: 10
            color: "#5b5b5b"
            text: control.separator
            font.bold: true
            font.pixelSize: 18
            visible: !twoFields
        }

        UbuntuLightText {
            id: rightText
            x: 191
            text: formatNumberLength(rightColumnValue, 2)
            color: "#5b5b5b"
            font.pixelSize: 18
            font.bold: true
            visible: !twoFields
        }
        UbuntuLightText {
            y: 30
            text: control.rightLabel
            anchors.horizontalCenter: rightText.horizontalCenter
            color: "#5b5b5b"
            visible: !twoFields
        }
    }

    Row {
        z: 1
        DateTimeButton {
            text: "-"
            onButtonClicked: leftMinusClicked()
        }

        DateTimeButton {
            text: "-"
            onButtonClicked: centerMinusClicked()
        }

        DateTimeButton {
            text: "-"
            onButtonClicked: rightMinusClicked()
            visible: !twoFields
        }
    }
}
