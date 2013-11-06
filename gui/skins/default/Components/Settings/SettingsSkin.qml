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
import "../../js/Stack.js" as Stack
import "../../js/default.js" as Default


MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * view.count)

    QtObject {
        id: privateProps
        property int skin
    }

    Component {
        id: alertComponent
        Alert {
            onAlertOkClicked: {
                var isDefault = false
                if (homeProperties.homeBgImage === Default.getDefaultHomeBg())
                    isDefault = true

                homeProperties.skin = privateProps.skin

                if (isDefault)
                    homeProperties.homeBgImage = Default.getDefaultHomeBg()

                Stack.backToHome()
            }
        }
    }

    ListView {
        id: view
        currentIndex: homeProperties.skin
        anchors.fill: parent
        interactive: false
        delegate: MenuItemDelegate {
            name: pageObject.names.get('SKIN', modelData)
            selectOnClick: false
            onDelegateTouched: {
                privateProps.skin = modelData
                pageObject.installPopup(alertComponent, {"message": qsTr("Pressing ok will cause a device reboot in a few moments.\nPlease, do not use the touch till it is restarted.\nContinue?")})
            }
        }
        model: [HomeProperties.Clear,
                HomeProperties.Dark]
    }
}
