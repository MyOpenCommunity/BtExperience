import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: control

    property variant itemObject: undefined
    property alias isEnabled: privateProps.enabled

    source: privateProps.isCustomTime() ? "../../images/common/bg_temporizzatore.svg" : "../../images/common/bg_temporizzatore_fisso.svg"

    QtObject {
        id: privateProps
        property bool enabled: true // in case of fixed timing remains always true

        function isCustomTime() {
            var oid = itemObject.objectId
            if (oid === ObjectInterface.IdDimmer100Custom || oid === ObjectInterface.IdLightCustom)
                return true
            return false
        }
    }

    UbuntuLightText {
        id: title
        color: "black"
        text: qsTr("timer")
        font.pixelSize: 13
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    Loader {
        id: timeLoader

        anchors {
            top: title.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        sourceComponent: privateProps.isCustomTime() ? customTimeComponent : fixedTimeComponent
    }

    Component {
        id: customTimeComponent

        Item {
            id: customFrame

            anchors.fill: parent

            UbuntuLightText {
                id: timing

                anchors {
                    verticalCenter: switchTiming.verticalCenter
                    left: parent.left
                    leftMargin: 7
                }
                font.pixelSize: 13
                color: "white"
                text: switchTiming.status === 0 ? qsTr("enabled") : qsTr("disabled")
            }

            Switch {
                id: switchTiming
                bgImage: "../../images/common/bg_cursore.svg"
                leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
                leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
                arrowImage: "../../images/common/ico_sposta_dx.svg"
                rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
                rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
                anchors {
                    top: parent.top
                    topMargin: 5
                    right: parent.right
                    rightMargin: 7
                }
                onClicked: privateProps.enabled = !privateProps.enabled
                status: !privateProps.enabled
            }

            ControlDateTime {
                id: timingButtons
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 11
                    left: parent.left
                    leftMargin: 7
                    right: parent.right
                    rightMargin: 7
                }
                enabled: privateProps.enabled
                itemObject: control.itemObject
            }
        }
    }

    Component {
        id: fixedTimeComponent

        Item {
            id: customFrame

            anchors.fill: parent

            ControlLeftRight {
                anchors.fill: parent
                text: pageObject.names.get('FIXED_TIMING', itemObject.ftime)
                onLeftClicked: {
                    if (itemObject.ftime <= -1)
                        return
                    itemObject.ftime -= 1
                }
                onRightClicked: {
                    if (itemObject.ftime >= 7)
                        return
                    itemObject.ftime += 1
                }
            }
        }
    }
}

