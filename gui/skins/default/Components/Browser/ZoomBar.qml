/**
  * An hiding bar showing zoom commands for browser
  */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Item {
    id: control

    property int zoomPercentage: 100

    signal zoomOutClicked
    signal zoomInClicked
    signal zoomHundredClicked

    height: if (loaderItem.item) loaderItem.item.height
    width: 230

    Loader {
        id: loaderItem

        anchors.fill: parent
    }

    Component {
        id: theBar

        SvgImage {
            id: bg

            source: "../../images/common/bg_barra.svg"

            ButtonImageThreeStates {
                id: hundredBarButton
                defaultImageBg: "../../images/common/btn_45x35.svg"
                pressedImageBg: "../../images/common/btn_45x35_P.svg"
                shadowImage: "../../images/common/btn_shadow_45x35.svg"
                defaultImage: "../../images/common/icon_zoom-100.svg"
                pressedImage: "../../images/common/icon_zoom-100_p.svg"
                repetitionOnHold: true
                onClicked: control.zoomHundredClicked()
                anchors {
                    left: parent.left
                    leftMargin: 10
                    top: parent.top
                    topMargin: 6
                }
            }

            ButtonImageThreeStates {
                id: minusBarButton
                defaultImageBg: "../../images/common/btn_45x35.svg"
                pressedImageBg: "../../images/common/btn_45x35_P.svg"
                shadowImage: "../../images/common/btn_shadow_45x35.svg"
                defaultImage: "../../images/common/icon_zoom-out.svg"
                pressedImage: "../../images/common/icon_zoom-out_p.svg"
                repetitionOnHold: true
                onClicked: control.zoomOutClicked()
                anchors {
                    left: hundredBarButton.right
                    leftMargin: 10
                    verticalCenter: hundredBarButton.verticalCenter
                }
            }

            ButtonImageThreeStates {
                id: plusBarButton
                defaultImageBg: "../../images/common/btn_45x35.svg"
                pressedImageBg: "../../images/common/btn_45x35_P.svg"
                shadowImage: "../../images/common/btn_shadow_45x35.svg"
                defaultImage: "../../images/common/icon_zoom-in.svg"
                pressedImage: "../../images/common/icon_zoom-in_p.svg"
                repetitionOnHold: true
                onClicked: control.zoomInClicked()
                anchors {
                    left: minusBarButton.right
                    leftMargin: 10
                    verticalCenter: hundredBarButton.verticalCenter
                }
            }

            UbuntuLightText {
                id: title
                text: zoomPercentage + "%"
                font.pixelSize: 16
                color: "white"
                anchors {
                    left: plusBarButton.right
                    leftMargin: 10
                    verticalCenter: plusBarButton.verticalCenter
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
