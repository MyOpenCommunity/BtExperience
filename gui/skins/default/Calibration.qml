import QtQuick 1.1
import BtExperience 1.0
import BtObjects 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack

BasePage {
    id: page

    property variant points: [{"p": {"x": 20, "y": 20}, "where": Calibration.TopLeft},
        {"p": {"x": 950, "y": 20}, "where": Calibration.TopRight},
        {"p": {"x": 950, "y": 550}, "where": Calibration.BottomRight},
        {"p": {"x": 20, "y": 550}, "where": Calibration.BottomLeft}
    ]
    property int currentPoint: 0

    Image {
        id: crosshair
        source: "images/common/ico_elimina.svg"

        Behavior on x { NumberAnimation { duration: 200; } }
        Behavior on y { NumberAnimation { duration: 200; } }
    }

    UbuntuLightText {
        text: qsTr("Click the crosshair")
        anchors.centerIn: page
    }

    MouseArea {
        anchors.fill: parent
        onReleased: {
            global.calibration.setCalibrationPoint(page.points[page.currentPoint].where,
                                                   page.points[page.currentPoint].p,
                                                   Qt.point(mouse.x, mouse.y))

            page.currentPoint += 1
            if (page.currentPoint >= page.points.length) {
                console.log("Calibration done")
                if (global.calibration.applyCalibration()) {
                    global.calibration.saveCalibration()
                }
                else {
                    global.calibration.resetCalibration()
                }

                Stack.popPage()
            }
            else {
                var nextPoint = page.points[page.currentPoint].p
                crosshair.x = nextPoint.x
                crosshair.y = nextPoint.y
            }
        }
    }

    Component.onCompleted: global.calibration.startCalibration()
}
