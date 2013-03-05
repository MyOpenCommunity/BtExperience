import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Column {
    property variant scenarioAction
    width: line.width
    spacing: 10
    opacity: 0.5

    UbuntuMediumText {
        text: qsTr("action")
        width: line.width
        elide: Text.ElideRight
        font.pixelSize: 18
        color: "white"
    }

    SvgImage {
        id: line
        source: "../../images/common/linea.svg"
    }

    UbuntuLightText {
        text: scenarioAction.target
        width: line.width
        elide: Text.ElideRight
        font.pixelSize: 14
        color: "white"
    }

    UbuntuLightText {
        text: scenarioAction.description
        width: line.width
        elide: Text.ElideRight
        font.pixelSize: 14
        color: "white"
    }
}

