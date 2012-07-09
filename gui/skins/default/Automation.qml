import QtQuick 1.1
import Components.Automation 1.0


SystemPage {
    source: "images/automazione.jpg"
    text: qsTr("automation")
    rootColumn: Component { AutomationItems {} }
}
