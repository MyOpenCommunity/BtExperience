import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: control

    property variant itemObject: undefined

    source: privateProps.isCustomTime() ? "../../images/common/bg_temporizzatore.svg" : "../../images/common/bg_temporizzatore_fisso.svg"

    QtObject {
        id: privateProps

        function isCustomTime() {
            var oid = itemObject.objectId

            if (oid === ObjectInterface.IdDimmer100CustomPP ||
                    oid === ObjectInterface.IdDimmer100CustomAMBGRGEN ||
                    oid === ObjectInterface.IdLightCustomPP ||
                    oid === ObjectInterface.IdLightCustomAMBGRGEN)
                return true

            return false
        }
    }

    UbuntuLightText {
        id: title
        color: "black"
        text: qsTr("timer")
        font.pixelSize: 15
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
                font.pixelSize: 15
                color: "white"
                text: itemObject.autoTurnOff ? qsTr("enabled") : qsTr("disabled")
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
                onPressed: itemObject.autoTurnOff = !itemObject.autoTurnOff
                status: !itemObject.autoTurnOff
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
                enabled: itemObject.autoTurnOff
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
                id: fixedTimeControl

                property int currentIndex // 0 means no auto turn off

                anchors.fill: parent
                text: currentIndex === 0 ? pageObject.names.get('FIXED_TIMING', -1) : pageObject.names.get('FIXED_TIMING', itemObject.ftimes.values[currentIndex - 1])
                onLeftClicked: {
                    if (currentIndex <= 0)
                        return
                    currentIndex -= 1
                    if (currentIndex === 0)
                        itemObject.autoTurnOff = false
                    else
                        itemObject.prevFTime()
                }
                onRightClicked: {
                    if (currentIndex >= itemObject.ftimes.values.length)
                        return
                    if (currentIndex === 0)
                        itemObject.autoTurnOff = true
                    else
                        itemObject.nextFTime()
                    currentIndex += 1
                }
                Component.onCompleted: {
                    currentIndex = 0
                    var fts = itemObject.ftimes.values
                    for (var i = 0; i < fts.length; ++i) {
                        if (itemObject.ftime === fts[i])
                            currentIndex = i + 1
                    }
                    itemObject.autoTurnOff = (currentIndex === 0 ? false : true)
                }
            }
        }
    }
}

