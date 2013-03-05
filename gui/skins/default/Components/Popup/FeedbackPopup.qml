import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

SvgImage {
    signal closePopup
    property alias text: label.text
    property bool isOk: true

    source: "../../images/scenarios/bg_feedback.svg"

    SvgImage {
        id: icon
        source: isOk ? "../../images/scenarios/ico_ok.svg" : "../../images/scenarios/ico_error.svg"
        anchors.left: parent.left
    }

    UbuntuMediumText {
        id: label
        text: qsTr("programming impossible")
        elide: Text.ElideRight
        anchors {
            left: icon.right
            leftMargin: parent.width / 100 * 2
            right: parent.right
            rightMargin: parent.width / 100 * 2
            verticalCenter: parent.verticalCenter
        }
        font.pixelSize: 18
    }

    Timer {
        interval: 2000
        running: true
        onTriggered: parent.closePopup();
    }
}
