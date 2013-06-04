import QtQuick 1.1
import Components.Automation 1.0
import BtObjects 1.0


/**
  \ingroup Automation

  \brief The Automation system page.
  */
SystemPage {
    source: "images/background/automation.jpg"
    text: systemNames.get(Container.IdAutomation)
    rootColumn: Component { AutomationItems {} }
}
