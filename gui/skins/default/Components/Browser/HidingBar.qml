/**
  * An hiding bar showing additional commands for browser (for example, zoom +/-)
  */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Item {
    id: control

    property int zoomPercentage: 100

    signal zoomOutClicked
    signal zoomInClicked

    height: if (loaderItem.item) loaderItem.item.height

    Loader {
        id: loaderItem

        anchors.fill: parent
    }

    Component {
        id: theBar

        SvgImage {
            id: bg

            source: "../../images/common/bg_barra.svg"

            UbuntuMediumText {
                id: title
                text: zoomPercentage + "%"
                font.pixelSize: 24
                color: "white"
                anchors {
                    right: minusBarButton.left
                    rightMargin: 10
                    verticalCenter: minusBarButton.verticalCenter
                }
            }

            ButtonImageThreeStates {
                id: minusBarButton
                defaultImageBg: "../../images/common/btn_45x35.svg"
                pressedImageBg: "../../images/common/btn_45x35_P.svg"
                shadowImage: "../../images/common/btn_shadow_45x35.svg"
                defaultImage: "../../images/common/ico_meno.svg"
                pressedImage: "../../images/common/ico_meno_P.svg"
                status: 0
                repetitionOnHold: true
                onClicked: control.zoomOutClicked()
                anchors {
                    right: plusBarButton.left
                    rightMargin: 10
                    top: parent.top
                    topMargin: 6
                }
            }

            ButtonImageThreeStates {
                id: plusBarButton
                defaultImageBg: "../../images/common/btn_45x35.svg"
                pressedImageBg: "../../images/common/btn_45x35_P.svg"
                shadowImage: "../../images/common/btn_shadow_45x35.svg"
                defaultImage: "../../images/common/ico_piu.svg"
                pressedImage: "../../images/common/ico_piu_P.svg"
                status: 0
                repetitionOnHold: true
                onClicked: control.zoomInClicked()
                anchors {
                    right: parent.right
                    rightMargin: 10
                    top: parent.top
                    topMargin: 6
                }
            }
        }
    }

    state: "hidden"

    states: [
        State {
            name: "hidden"
            extend: ""
        },
        State {
            name: "visible"
            PropertyChanges {
                target: loaderItem
                sourceComponent: theBar
            }
        }
    ]
}
