import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: element

    property int partialId: 1
    property alias text: consumption.text
    property alias since: since.text

    signal clicked

    source: "../../images/common/bg_panel_212x100.svg"

    UbuntuLightText {
        id: firstLine

        text: qsTr("partial ") + (element.partialId + 1) // expects periodTotals are zero-based
        color: "gray"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            top: parent.top
            topMargin: parent.height / 100 * 5
            left: parent.left
            leftMargin: parent.width / 100 * 5
        }
    }

    UbuntuLightText {
        id: since

        text: qsTr("since 24/07/2012 18:35")
        color: "gray"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            top: firstLine.bottom
            topMargin: parent.height / 100 * 5
            left: firstLine.left
        }
    }

    UbuntuLightText {
        id: consumption

        text: qsTr("45.51 kWh")
        color: "white"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            left: firstLine.left
            verticalCenter: buttonReset.verticalCenter
        }
    }

    ButtonThreeStates {
        id: buttonReset

        defaultImage: "../../images/common/btn_66x35.svg"
        pressedImage: "../../images/common/btn_66x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_66x35.svg"
        text: qsTr("reset")
        font.capitalization: Font.AllUppercase
        font.pixelSize: 15
        onClicked: element.clicked()
        status: 0
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height / 100 * 10
            right: parent.right
            rightMargin: parent.width / 100 * 4
        }
    }
}
