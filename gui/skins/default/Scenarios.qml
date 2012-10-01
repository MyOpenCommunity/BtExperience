import QtQuick 1.1
import Components.Scenarios 1.0


SystemPage {
    source: "images/scenario.jpg"
    text: qsTr("Scenarios")
    rootColumn: Component { ScenarioSystem {} }
}
