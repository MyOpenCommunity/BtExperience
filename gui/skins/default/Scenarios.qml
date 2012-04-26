import QtQuick 1.1
import Components.Scenarios 1.0


SystemPage {
    source: "images/scenari.jpg"
    text: qsTr("Scenarios")
    rootColumn: scenarioSystem

    Component {
        id: scenarioSystem
        ScenarioSystem {}
    }
}
