import QtQuick 1.1
import BtObjects 1.0
import Components.ThermalRegulation 1.0


/**
  \ingroup ThermalRegulation

  \brief The ThermalRegulation system page.
  */
SystemPage {
    source: "images/background/temperature_control_heating.jpg"
    text: systemNames.get(Container.IdThermalRegulation)
    rootColumn: Component { ThermalRegulationItems {} }
    names: ThermalNames {}
}

