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


ColumnBrowserCommon {

    property variant rootPath
    property alias filter: upnpModel.filter
    property bool restoreState

    theModel: upnpModel
    text: upnpModel.serverList ? "Media Server" : upnpModel.currentPath[upnpModel.currentPath.length - 1]

    UPnPListModel {
        id: upnpModel
        filter: FileObject.All
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    Component.onCompleted: {
        if (restoreState)
            global.audioVideoPlayer.restoreUpnpState(upnpModel)
    }
}
