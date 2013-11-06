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
import Components 1.0


MenuColumn {
    id: column

    ObjectModel {
        // this must stay here otherwise messagesModel cannot be constructed properly
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMessages}]
    }

    MediaModel {
        // this must stay here for count call to work
        id: messagesModel
        source: objectModel.getObject(0).messages
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        // in a MenuColumn we need a Column... :(
        MenuItem {
            // TODO: this must be the number of *unread* messages
            property int numberOfMessages: messagesModel.count
            name: qsTr("inbox")
            isSelected: privateProps.currentIndex === 1
            hasChild: true
            boxInfoState: numberOfMessages > 0 ? "info" : ""
            boxInfoText: numberOfMessages

            onTouched: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(columnMessages, qsTr("Received messages"))
            }
        }
    }

    Component {
        id: columnMessages
        ColumnMessages {}
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }
}
