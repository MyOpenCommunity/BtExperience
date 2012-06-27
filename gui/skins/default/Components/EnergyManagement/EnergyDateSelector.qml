import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Row {
    id: selector
    property date date: new Date()

    spacing: 4

    ButtonImageThreeStates {
        defaultImageBg: "../images/energy/btn_freccia.svg"
        pressedImageBg: "../images/energy/btn_freccia_P.svg"
        shadowImage: "../images/energy/ombra_btn_freccia.svg"

        defaultImage: "../images/common/ico_freccia_sx.svg"
        pressedImage: "../images/common/ico_freccia_sx_P.svg"
        onClicked: {
            var d = selector.date
            var month = d.getMonth()
            if (month == 0) {
                d.setFullYear(d.getFullYear() - 1)
                d.setMonth(11)
            }
            else {
                d.setMonth(month -1)
            }
            selector.date = d
        }

        enabled: {
            var d = new Date()
            if (selector.date.getFullYear() > d.getFullYear() - 2)
                return true

            if (selector.date.getMonth() > d.getMonth())
                return true
            return false
        }

        Rectangle {
            z: 1
            anchors.fill: parent
            color: "silver"
            opacity: 0.6
            visible: parent.enabled === false
        }
    }

    SvgImage {
        source: "../../images/energy/btn_selectDMY.svg"

        UbuntuLightText {
            id: textLabel
            text: qsTr("month")
            font.pixelSize: 14
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
        }

        UbuntuLightText {
            font.pixelSize: 13
            text: Qt.formatDateTime(selector.date, qsTr("MM/yyyy"))
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: textLabel.bottom
                topMargin: 5
            }
        }

        SvgImage {
            anchors {
                left: parent.left
                top: parent.bottom
                right: parent.right
            }
            source: "../../images/energy/ombra_btn_selectDMY.svg"
        }
    }

    ButtonImageThreeStates {
        defaultImageBg: "../images/energy/btn_freccia.svg"
        pressedImageBg: "../images/energy/btn_freccia_P.svg"
        shadowImage: "../images/energy/ombra_btn_freccia.svg"

        defaultImage: "../images/common/ico_freccia_dx.svg"
        pressedImage: "../images/common/ico_freccia_dx_P.svg"

        enabled: {
            var d = new Date()
            if (selector.date.getMonth() === d.getMonth() && selector.date.getFullYear() === d.getFullYear())
                return false
            return true
        }

        Rectangle {
            z: 1
            anchors.fill: parent
            color: "silver"
            opacity: 0.6
            visible: parent.enabled === false
        }

        onClicked: {
            var d = selector.date
            var month = d.getMonth()
            if (month == 11) {
                d.setFullYear(d.getFullYear() + 1)
                d.setMonth(0)
            }
            else {
                d.setMonth(month + 1)
            }
            selector.date = d
        }

    }
}
