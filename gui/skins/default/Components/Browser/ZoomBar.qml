/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


/**
  \ingroup Core

  \brief An hiding bar showing zoom commands for browser

  A zoom bar for the browser component. It contains buttons to zoom out, zoom in
  and to restore zoom at 100%. It contains only graphic and it emits proper
  signals when buttons are clicked.
  */
Item {
    id: control

    /// the zoom percentage level
    property int zoomPercentage: 100

    /// the zoom out button was clicked
    signal zoomOutClicked
    /// the zoom in button was clicked
    signal zoomInClicked
    /// the zoom reset button was clicked
    signal zoomHundredClicked

    width: 230
    height: 49

    Connections {
        target: global
        onAboutToHide: {
            control.state = "hidden"
            control.zoomPercentage = 100
        }
    }

    Loader {
        id: loaderItem

        anchors.fill: parent
    }

    Component {
        id: theBar

        SvgImage {
            id: bg

            source: "../../images/common/bg_panel_212x100.svg"
            anchors.fill: parent

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
