/**
  * A component implemeting a header for the web browser component.
  */

import QtQuick 1.1
import Components 1.0


SvgImage {
    id: control

    property bool urlChanged: false
    property alias editUrl: urlInput.url
    property variant view
    property variant browser

    signal hidingBarClicked
    signal urlEntered(string url)

    function updateImages(s) {
        if (s === "hidden") {
            hidingBarButton.defaultImage = "../../images/common/icon_browser-option.svg"
            hidingBarButton.pressedImage = "../../images/common/icon_browser-option_p.svg"
        }
        else {
            hidingBarButton.defaultImage = "../../images/common/icon_browser-option_open.svg"
            hidingBarButton.pressedImage = "../../images/common/icon_browser-option_open_p.svg"
        }
    }

    source: "../../images/common/bg_barra.svg"
    x: view.contentX < 0 ?
           -view.contentX :
           view.contentX > view.contentWidth-view.width ?
               -view.contentX+view.contentWidth-view.width :
               0
    y: view.progress < 1.0 ?
           0 :
           view.contentY < 0 ?
               -view.contentY :
               view.contentY > height ?
                   -height : -view.contentY

    ButtonImageThreeStates {
        id: backButton
        defaultImageBg: "../../images/common/btn_45x35.svg"
        pressedImageBg: "../../images/common/btn_45x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_45x35.svg"
        defaultImage: "../../images/common/ico_indietro.svg"
        pressedImage: "../../images/common/ico_indietro_P.svg"
        onClicked: view.back.trigger()
        anchors {
            left: parent.left
            leftMargin: 20
            top: parent.top
            topMargin: 6
        }
    }

    ButtonImageThreeStates {
        id: forwardButton
        defaultImageBg: "../../images/common/btn_45x35.svg"
        pressedImageBg: "../../images/common/btn_45x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_45x35.svg"
        defaultImage: "../../images/common/ico_avanti.svg"
        pressedImage: "../../images/common/ico_avanti_P.svg"
        onClicked: view.forward.trigger()
        anchors {
            left: backButton.right
            leftMargin: 4
            top: parent.top
            topMargin: 6
        }
    }

    SvgImage {
        id: bgText

        source: "../../images/common/bg_testo.svg"
        anchors {
            left: forwardButton.right
            leftMargin: 10
            top: parent.top
            topMargin: 6
            right: parent.right
            rightMargin: 30 + actionButton.width + closeBrowser.width + hidingBarButton.width
        }
    }

    ButtonImageThreeStates {
        id: hidingBarButton
        defaultImageBg: "../../images/common/btn_45x35.svg"
        pressedImageBg: "../../images/common/btn_45x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_45x35.svg"
        defaultImage: "../../images/common/icon_browser-option.svg"
        pressedImage: "../../images/common/icon_browser-option_p.svg"
        onClicked: control.hidingBarClicked()
        anchors {
            left: bgText.right
            leftMargin: 10
            top: parent.top
            topMargin: 6
        }
    }

    ButtonImageThreeStates {
        id: actionButton
        defaultImageBg: "../../images/common/btn_45x35.svg"
        pressedImageBg: "../../images/common/btn_45x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_45x35.svg"
        defaultImage: "../../images/common/ico_aggiorna.svg"
        pressedImage: "../../images/common/ico_aggiorna_P.svg"
        onClicked: {
            if (control.state === "") {
                view.reload.trigger()
            }
            else if (control.state === "loading") {
                view.stop.trigger()
            }
            else if (control.state === "editing") {
                browser.urlString = urlInput.url
                browser.focus = true
                control.urlChanged = false
            }
        }
        anchors {
            left: hidingBarButton.right
            leftMargin: 4
            top: parent.top
            topMargin: 6
        }
    }

    SvgImage {
        id: loadingIndicator

        source: "../../images/common/ico_caricamento.svg"
        visible: false
        anchors {
            top: bgText.top
            right: bgText.right
        }

        Timer {
            id: loadingTimer
            interval: 250
            repeat: true
            onTriggered: loadingIndicator.rotation += 45
        }
    }

    Item {
        id: closeBrowser
        width: 36
        height: 35
        anchors {
            top: bgText.top
            left: actionButton.right
            leftMargin: 10
        }

        SvgImage {
            id: closeIcon
            anchors.right: parent.right
            source: "../../images/common/button_close.svg"
            states: [
                State {
                    name: "pressed"
                    PropertyChanges {
                        target: closeIcon
                        source: "../../images/common/button_close_p.svg"
                    }
                }
            ]
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // looks for last visible browser window and hides it
                // if the to be hidden window is the last one, quits
                var children = webBrowser.children
                var windows = 0
                var ghost = undefined
                for (var i = 0; i < children.length; ++i) {
                    var child = children[i]
                    if (child._fixedUrlString) // this is a browserItem
                        if (child.visible) { // last visible one must be hidden
                            ++windows
                            ghost = child
                        }
                }
                if (windows <= 1) // last window
                    global.quit()
                else
                    // the popup object is created with C++ ownership, hence there is no way
                    // to destroy it from QML; calling deleteLater() from C++ appears to be the
                    // correct way to free the object
                    global.destroyQmlItem(ghost)
            }
            onPressed: closeIcon.state = "pressed"
            onReleased: closeIcon.state = ""
        }
    }

    UrlInput {
        id: urlInput
        view: control.view
        anchors {
            verticalCenter: bgText.verticalCenter
            left: bgText.left
            right: loadingIndicator.visible ? loadingIndicator.left : bgText.right
        }
        onUrlEntered: {
            browser.focus = true
            control.urlChanged = false
            control.urlEntered(url)
        }
        onUrlChanged: control.urlChanged = true
    }

    states: [
        State {
            name: "loading"
            when: view.progress < 1.0 && !control.urlChanged
            PropertyChanges {
                target: loadingIndicator
                visible: true
            }
            PropertyChanges {
                target: loadingTimer
                running: true
            }
            PropertyChanges {
                target: actionButton
                defaultImage: "../../images/common/ico_elimina.svg"
                pressedImage: "../../images/common/ico_elimina_P.svg"
            }
        },
        State {
            name: "editing"
            when: view.progress === 1.0 && control.urlChanged
            PropertyChanges {
                target: actionButton
                defaultImage: "../../images/common/ico_vai.svg"
                pressedImage: "../../images/common/ico_vai_P.svg"
            }
        }
    ]
}
