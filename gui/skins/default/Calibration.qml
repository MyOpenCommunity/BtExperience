import QtQuick 1.1
import BtExperience 1.0
import BtObjects 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack

BasePage {
    id: page

    property int offset: 50

    property variant points: [
        {"p": {"x": offset, "y": offset}, "where": Calibration.TopLeft},
        {"p": {"x": width - offset, "y": offset}, "where": Calibration.TopRight},
        {"p": {"x": width - offset, "y": height - offset}, "where": Calibration.BottomRight},
        {"p": {"x": offset, "y": height - offset}, "where": Calibration.BottomLeft},
        {"p": {"x": width / 2, "y": height / 2}, "where": Calibration.Center}
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
        anchors.verticalCenterOffset: -page.height / 4
    }

    function updateCrosshair() {
        var nextPoint = page.points[page.currentPoint].p
        crosshair.x = nextPoint.x - crosshair.width / 2
        crosshair.y = nextPoint.y - crosshair.height / 2
    }

    Connections {
        target: global.calibration
        onRawMousePress: {
            global.calibration.setCalibrationPoint(page.points[page.currentPoint].where,
                                                   Qt.point(page.points[page.currentPoint].p.x, page.points[page.currentPoint].p.y),
                                                   Qt.point(x, y))

            page.currentPoint += 1
            if (page.currentPoint >= page.points.length) {
                console.log("Calibration done")
                if (global.calibration.applyCalibration()) {
                    global.calibration.saveCalibration()
                    Stack.popPage()
                    return
                }
                else {
                    global.calibration.resetCalibration()
                    currentPoint = 0
                }
            }

            updateCrosshair()
        }
    }

    Component.onCompleted: {
        global.calibration.startCalibration()
        updateCrosshair()
    }
}
