import QtQuick 1.1
import Components.ThermalRegulation 1.0


/**
  \ingroup ThermalRegulation

  \brief The ThermalRegulation system page.
  */
SystemPage {
    source: "images/background/temperature_control_heating.jpg"
    text: qsTr("temperature control")
    rootColumn: Component { ThermalRegulationItems {} }
    names: ThermalNames {}
}

