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
import BtObjects 1.0
import "../../js/logging.js" as Log


MenuColumn {
    id: column

    Component {
        id: programListSplit
        ProgramListSplit {
            onProgramSelected: dataModel.program = program
        }
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        id: paginator

        MenuItem {
            id: programItem
            name: qsTr("program")
            description: dataModel.program.name
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onTouched: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(programListSplit, name, dataModel)
            }
        }

        ButtonOkCancel {
            onCancelClicked: column.closeColumn()
            onOkClicked: {
                dataModel.apply()
                column.closeColumn()
            }
        }
    }
}
