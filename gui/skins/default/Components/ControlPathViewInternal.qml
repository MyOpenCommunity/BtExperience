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
import Components.Text 1.0


PathView {
    id: control

    // defaults are related to home page
    property int x0FiveElements: control.width / 100 * 15
    property int x0ThreeElements: control.width / 100 * 20
    property int x1: control.width / 2
    property int x2FiveElements: control.width - x0FiveElements
    property int x2ThreeElements: control.width - x0ThreeElements
    property int y0: control.height / 100 * 55
    property int y1: control.height / 100 * 50
    property int y2: y0
    property int pathOffset: 0

    property int currentPressed: -1

    signal clicked(variant delegate)
    signal internalClick()

    delegate: PathViewDelegate {
        id: viewDelegate
        itemObject: control.model.getObject(index)
        z: PathView.elementZ || 0
        scale: PathView.elementScale || 1
        opacity: PathView.elementOpacity || 1
        onDelegateClicked: {
            // here is the entry point to trigger the card action; it is a
            // good time to beep :) this is useful to catch all beep "paths"
            // in pathview
            if (global.guiSettings.beep)
                global.beep()
            control.clicked(delegate)
        }

        Connections {
            target: control
            onInternalClick: {
                if (index === control.currentPressed)
                    viewDelegate.delegateClicked(viewDelegate.itemObject)
            }
        }
    }

    path: Path {
        startX: firstSegment.x - 5
        startY: firstSegment.y
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathAttribute { name: "elementOpacity"; value: 0 }
        PathLine {
            id: firstSegment
            x: (control.model.count < 5 ? x0ThreeElements : x0FiveElements) + pathOffset
            y: y0
        }
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathAttribute { name: "elementOpacity"; value: 1 }
        PathLine {
            x: x1 + pathOffset
            y: y1
        }
        PathAttribute { name: "elementScale"; value: 1.0 }
        PathAttribute { name: "elementZ"; value: 1 }
        PathAttribute { name: "elementOpacity"; value: 1 }
        PathLine {
            id: lastSegment
            x: (control.model.count < 5 ? x2ThreeElements : x2FiveElements) + pathOffset
            y: y2
        }
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathAttribute { name: "elementOpacity"; value: 1 }
        PathLine {
            x: lastSegment.x + 5
            y: lastSegment.y
        }
        PathAttribute { name: "elementScale"; value: 0.5 }
        PathAttribute { name: "elementZ"; value: 0.5 }
        PathAttribute { name: "elementOpacity"; value: 0 }
    }

    function visibleItems() {
        var result = control.model.count
        if (result <= 3)
            return 3
        if (result > 7)
            return 7
        return result
    }

    pathItemCount: control.visibleItems()
    highlightRangeMode: PathView.StrictlyEnforceRange
    // 4 and 6 cards are special cases; we need to change to 0.49 to make the 4th (6th)
    // card visible
    preferredHighlightBegin: (pathItemCount % 2) === 0 ? 0.49 : 0.5
    preferredHighlightEnd: (pathItemCount % 2) === 0 ? 0.49 : 0.5

    onFlickStarted: {
        currentPressed = -1
    }
    onMovementEnded: {
        if (global.maxTravelledDistanceOnLastMove().x < 20)
            control.internalClick()
        currentPressed = -1
    }
}
