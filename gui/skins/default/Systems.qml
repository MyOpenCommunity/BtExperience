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
import BtExperience 1.0
import Components 1.0
import "js/Stack.js" as Stack
import "js/Systems.js" as Script


/**
  \ingroup Core

  \brief The entry page for all systems.
  */
Page {
    id: systems

    source : homeProperties.homeBgImage
    text: qsTr("functions")

    ObjectModel {
        id: systemsModel
        source: myHomeModels.systems
    }

    SystemsNames {
        id: names
    }

    Loader {
        id: viewLoader
        anchors {
            top: toolbar.bottom
            right: parent.right
            rightMargin: 30
            left: navigationBar.right
            leftMargin: 30
            bottom: parent.bottom
        }
        sourceComponent: systemsModel.count >= 3 ? cardPathView : cardList
    }

    Component {
        id: cardPathView

        ControlPathView {
            x0FiveElements: 150
            x0ThreeElements: 250
            y0: 270
            x1: 445
            y1: 250
            x2FiveElements: 740
            x2ThreeElements: 640
            pathviewId: 3
            model: systemsModel
            pathOffset: model.count === 4 ? -40 : (model.count === 6 ? -40 : 0)
            arrowsMargin: model.count === 4 ? 70 : (model.count === 6 ? 30 : 10)
            onClicked: Stack.goToPage(Script.getTarget(delegate.containerId))
        }
    }

    Component {
        id: cardList
        CardView {
            delegate: CardDelegate {
                itemObject: systemsModel.getObject(index)
                onClicked: Stack.goToPage(Script.getTarget(itemObject.containerId))
            }

            model: systemsModel
        }
    }

    Component.onCompleted: {
        systemsModel.containers = Script.systemsModelContainers(systemsModel)
        for (var i = 0; i < systemsModel.count; ++i) {
            var itemObject = systemsModel.getObject(i)
            itemObject.description = names.get(itemObject.containerId)
        }
    }
}
