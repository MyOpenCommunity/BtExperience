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
        defaultImageBg: "../../images/common/btn_browser.svg"
        pressedImageBg: "../../images/common/btn_browser_P.svg"
        shadowImage: "../../images/common/ombra_btn_browser.svg"
        defaultImage: "../../images/common/ico_indietro.svg"
        pressedImage: "../../images/common/ico_indietro_P.svg"
        status: 0
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
        defaultImageBg: "../../images/common/btn_browser.svg"
        pressedImageBg: "../../images/common/btn_browser_P.svg"
        shadowImage: "../../images/common/ombra_btn_browser.svg"
        defaultImage: "../../images/common/ico_avanti.svg"
        pressedImage: "../../images/common/ico_avanti_P.svg"
        status: 0
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
            rightMargin: 30 + actionButton.width
        }
    }

    ButtonImageThreeStates {
        id: actionButton
        defaultImageBg: "../../images/common/btn_browser.svg"
        pressedImageBg: "../../images/common/btn_browser_P.svg"
        shadowImage: "../../images/common/ombra_btn_browser.svg"
        defaultImage: "../../images/common/ico_aggiorna.svg"
        pressedImage: "../../images/common/ico_aggiorna_P.svg"
        status: 0
        onClicked: {
            if (state === "") {
                view.reload.trigger()
            }
            else if (state === "loading") {
                view.stop.trigger()
            }
            else if (state === "editing") {
                browser.urlString = urlInput.url
                browser.focus = true
                control.urlChanged = false
            }
        }
        anchors {
            left: bgText.right
            leftMargin: 10
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

    UrlInput {
        id: urlInput
        view: control.view
        anchors {
            verticalCenter: bgText.verticalCenter
            left: bgText.left
            right: bgText.right
        }
        onUrlEntered: {
            browser.urlString = url
            browser.focus = true
            control.urlChanged = false
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
