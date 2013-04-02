import QtQuick 1.1
import Components 1.0
import Components.Settings 1.0
import Components.Text 1.0
import Components.ThermalRegulation 1.0
import "js/MainContainer.js" as Container
import "js/Stack.js" as Stack
import "js/EventManager.js" as EventManagerContainer


/**
  \ingroup Core

  \brief The main application component.

  This is the main application component. It shows the HomePage, but it is not
  itself visible because pages are managed by the Stack component.
  Contains video resolution, font used by the application, the EventManager and
  it runs startup application code.
  */
Item {
    id: container

    property alias animation: animationManager.animation
    property alias animationType: animationManager.type
    property alias ubuntuLight: ubuntuLightLoader
    property alias ubuntuMedium: ubuntuMediumLoader

    width: 1024
    height: 600
    transform: Scale { origin.x: 0; origin.y: 0; xScale: global.mainWidth / 1024; yScale: global.mainHeight / 600 }

    Component.onCompleted: {
        global.initAudio()

        Container.mainContainer = container
        EventManagerContainer.eventManager = eventManagerId
        // We need to update the reference in Stack because it includes MainContainer
        // but it doesn't get the updates to it, because in QtQuick 1.1 Qt.include()
        // in a JS file operates a literal inclusion, not a real variable
        // sharing
        // http://qt-project.org/forums/viewthread/18372
        Stack.mainContainer = container
        Stack.debugTiming = global.debugTiming

        Stack.pushPage("HomePage.qml")

        if (!global.calibration.exists())
            Stack.pushPage("Calibration.qml")
    }

    FontLoader {
        id: ubuntuLightLoader
        source: "Components/Text/Ubuntu-L.ttf"
    }

    FontLoader {
        id: ubuntuMediumLoader
        source: "Components/Text/Ubuntu-M.ttf"
    }

    AnimationManager {
        id: animationManager
    }

    EventManager {
        id: eventManagerId
        anchors.fill: parent
        transform: Scale { origin.x: 0; origin.y: 0; xScale: 1024 / global.mainWidth; yScale: 600 / global.mainHeight }
        // the EventManager must show some pages on top of everything else:
        // let's make it very "high"
        z: 1000
    }

    MouseArea {
        anchors.fill: parent
        z: eventManagerId.z + 1
        onPressed: {
            if (global.debugTs) {
                var dot = Qt.createComponent("Components/PressDot.qml")
                dot.createObject(container, {"x": mouseX, "y": mouseY})
                onClicked: console.log( mouseX, mouseY)
            }
            mouse.accepted = false
        }
    }

    // precompiling some components
    Component { SvgImage { source: "images/common/menu_column_item_arrow_white.svg" } }
    Component { SvgImage { source: "images/common/menu_column_item_bg_pressed.svg" } }
    Component { SvgImage { source: "images/menu_column/label_column-title.svg" } }
    Component { SvgImage { source: "images/menu_column/label_column-title_p.svg" } }
    Component { Paginator {} }
    Component { MenuTitle {} }
    Component { SettingsHome {} }
    Component { SettingsGenerals {} }
    Component { SettingsProfiles {} }
    Component { Floor {} }
    Component { SettingsSystems {} }
    Component { SettingsClocks {} }
    Component { SettingsMultimedia {} }
    Component { SettingsRingtones {} }
    Component { ThermalRegulationItems {} }
    Component { ThermalRegulator {} }
    Component { ThermalControlUnit {} }
    Component { ThermalControlledProbe {} }
    Component { BasicSplit {} }
    Component { AdvancedSplit {} }
    Component { AirConditioning {} }
    Component { NotControlledProbes {} }
    Component { ExternalProbes {} }
}
