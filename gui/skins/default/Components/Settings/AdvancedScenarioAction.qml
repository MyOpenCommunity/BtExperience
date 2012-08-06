import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Column {
    property variant scenarioAction
    width: line.width
    spacing: 10

    UbuntuMediumText {
        text: qsTr("action")
        font.pixelSize: 18
        color: "white"
    }

    SvgImage {
        id: line
        source: "../../images/common/linea.svg"
    }

    UbuntuLightText {
        text: scenarioAction.target
        font.pixelSize: 14
        color: "white"
    }

    UbuntuLightText {
        text: scenarioAction.description
        font.pixelSize: 14
        color: "white"
    }

}
