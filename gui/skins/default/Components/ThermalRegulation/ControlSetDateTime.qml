import QtQuick 1.1
import Components 1.0

ControlSettings {
    id :control
    property alias date: control.upperText
    property alias time: control.bottomText
    property alias dateVisible: control.upperLabelVisible
    upperLabel: qsTr("until date")
    bottomLabel: qsTr("until time")
}

