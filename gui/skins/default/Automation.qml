import QtQuick 1.1
import Components.Automation 1.0


/**
  \ingroup Automation

  \brief The Automation system page.
  */
SystemPage {
    source: "images/background/automation.jpg"
    text: qsTr("automation")
    rootColumn: Component { AutomationItems {} }
}
