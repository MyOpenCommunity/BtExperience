import QtQuick 1.1
import Components 1.0

Column {
    id: control
    property int leftColumnValue: 2
    property int centerColumnValue: 3
    property int rightColumnValue: 8
    property string leftLabel: "left"
    property string centerLabel: "very center"
    property string rightLabel: "sh"
    property string separator: ":"


    function leftPlusClicked() {
        leftColumnValue += 1
    }

    function centerPlusClicked() {
        centerColumnValue += 1
    }

    function rightPlusClicked() {
        rightColumnValue +=1
    }

    function leftMinusClicked() {
        if (leftColumnValue > 0)
            leftColumnValue -= 1
    }

    function centerMinusClicked() {
        if (centerColumnValue > 0)
            centerColumnValue -= 1
    }

    function rightMinusClicked() {
        if (rightColumnValue > 0)
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
        }
    }

    SvgImage {
        source: "../../images/common/date_panel_inner_background.svg"

        Text {
            id: leftText
            x: 27
            text: formatNumberLength(leftColumnValue, 2)
            color: "#5b5b5b"
            font.pointSize: 18
            font.bold: true
        }
        Text {
            text: control.leftLabel
            y: 30
            anchors.horizontalCenter: leftText.horizontalCenter
            color: "#5b5b5b"
        }

        Text {
            id: separator1
            x: 79
            y: 10
            text: control.separator
            color: "#5b5b5b"
            font.pointSize: 18
            font.bold: true
        }


        Text {
            id: centerText
            x: 109
            text: formatNumberLength(centerColumnValue, 2)
            color: "#5b5b5b"
            font.pointSize: 18
            font.bold: true
        }
        Text {
            y: 30
            text: control.centerLabel
            anchors.horizontalCenter: centerText.horizontalCenter
            color: "#5b5b5b"
        }

        Text {
            id: separator2
            x: 162
            y: 10
            color: "#5b5b5b"
            text: control.separator
            font.bold: true
            font.pointSize: 18
        }

        Text {
            id: rightText
            x: 191
            text: formatNumberLength(rightColumnValue, 2)
            color: "#5b5b5b"
            font.pointSize: 18
            font.bold: true
        }
        Text {
            y: 30
            text: control.rightLabel
            anchors.horizontalCenter: rightText.horizontalCenter
            color: "#5b5b5b"
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
        }
    }
}
