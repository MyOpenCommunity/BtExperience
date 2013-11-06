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

/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the QtDeclarative module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation and
** appearing in the file LICENSE.LGPL included in the packaging of this
** file. Please review the following information to ensure the GNU Lesser
** General Public License version 2.1 requirements will be met:
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Nokia gives you certain additional
** rights. These rights are described in the Nokia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU General
** Public License version 3.0 as published by the Free Software Foundation
** and appearing in the file LICENSE.GPL included in the packaging of this
** file. Please review the following information to ensure the GNU General
** Public License version 3.0 requirements will be met:
** http://www.gnu.org/copyleft/gpl.html.
**
** Other Usage
** Alternatively, this file may be used in accordance with the terms and
** conditions contained in a signed written agreement between you and Nokia.
**
**
**
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 1.1
import QtWebKit 1.0
import "fragmentloader.js" as Script

Flickable {
    property alias title: webView.title
    property alias icon: webView.icon
    property alias progress: webView.progress
    property alias url: webView.url
    property alias html: webView.html
    property alias back: webView.back
    property alias stop: webView.stop
    property alias reload: webView.reload
    property alias forward: webView.forward
    property int zoomPercentage: 100

    id: flickable
    contentWidth: Math.max(parent.width,webView.width)
    contentHeight: Math.max(parent.height,webView.height)
    pressDelay: 200
    boundsBehavior: Flickable.StopAtBounds

    onWidthChanged : {
        // Expand (but not above 1:1) if otherwise would be smaller that available width.
        if (width > webView.width*webView.contentsScale && webView.contentsScale < 1.0)
            webView.contentsScale = width / webView.width * webView.contentsScale;
    }
    onZoomPercentageChanged: webView.contentsScale = zoomPercentage / 100

    WebView {
        id: webView

        newWindowComponent: browserComponent
        newWindowParent: webBrowser
        settings.javascriptCanOpenWindows: true

        smooth: false // We don't want smooth scaling, since we only scale during (fast) transitions
        focus: true

        javaScriptWindowObjects: QtObject {
            id: fragmentPosition
            property int y: 0

            WebView.windowObjectName: "fragmentPosition"
        }

        onAlert: console.log(message)
        onLoadFailed: console.log("Error loading: " + url)
        onLoadFinished: {
            console.log("Finished loading: " + url)
            var u = url.toString()
            var fragment = extractFragment(u)
            evaluateJavaScript(Script.getFragmentPositionString(fragment))
            anchorAnimation.toY = Math.min(fragmentPosition.y*contentsScale, flickable.contentHeight-flickable.height)
            anchorAnimation.running = true
        }
        onLoadStarted: {
            flickable.contentX = 0
            flickable.contentY = 0
            console.log("Started loading new url " + url)
        }

        preferredWidth: flickable.width
        preferredHeight: flickable.height
        contentsScale: 1

        function extractFragment(url) {
            var idx = url.lastIndexOf("#")
            if (idx === -1)
                return ""
            return url.substring(idx + 1)
        }

        onUrlChanged: {
            fragmentPosition.y = 0
            if (url !== null)
                header.editUrl = url.toString()
        }

        ParallelAnimation {
            id: anchorAnimation
            property alias toY: yanim.to
            NumberAnimation {
                id: yanim
                target: flickable
                property: "contentY"
                to: 0
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }
    }
}
