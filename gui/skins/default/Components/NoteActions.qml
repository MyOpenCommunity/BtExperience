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
import BtObjects 1.0


Column {
    id: column

    signal editClicked
    signal deleteClicked

    opacity: 0

    Rectangle {
        width: 48
        height: 48
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#b7b7b7";
            }
            GradientStop {
                position: 1.00;
                color: "#ffffff";
            }
        }
        Image {
            source: "../images/icon_pencil.png"
            anchors.fill: parent
            anchors.margins: 10
        }

        BeepingMouseArea {
            anchors.fill: parent
            onClicked: column.editClicked()
        }
    }

    Rectangle {
        width: 48
        height: 48
        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#b7b7b7";
            }
            GradientStop {
                position: 1.00;
                color: "#ffffff";
            }
        }
        Image {
            source: "../images/icon_trash.png"
            anchors.fill: parent
            anchors.margins: 10
        }

        BeepingMouseArea {
            anchors.fill: parent
            onClicked: column.deleteClicked()
        }
    }

    Behavior on opacity {
        NumberAnimation { target: column; property: "opacity"; duration: 200;}
    }

    states: [
        State {
            name: "selected"
            PropertyChanges {
                target: column
                opacity: 1
            }
        }
    ]
}
