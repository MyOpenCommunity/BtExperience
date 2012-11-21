import QtQuick 1.1
import QtWebKit 1.0
import Components 1.0
import Components.Browser 1.0


Rectangle {
    id: bg

    width: 600
    height: 400
    anchors {
        top: parent.top
        topMargin: 40
        left: parent.left
        leftMargin: 40
    }

    MenuShadow {
        anchors.fill: parent
    }

    SvgImage {
        id: bar
        source: "../../images/common/bg_barra.svg"
        anchors {
            top: bg.top
            left: bg.left
            right: bg.right
        }
    }

    Pannable {
        id: browser

        anchors {
            top: bar.bottom
            left: bg.left
            right: bg.right
            bottom: bg.bottom
        }

        FlickableWebView {
            id: webView
            clip: true
            x: 0
            y: parent.childOffset
            width: parent.width
            height: parent.height
        }
    }

    ButtonImageThreeStates {
        id: closeButton
        defaultImageBg: "../../images/common/btn_browser.svg"
        pressedImageBg: "../../images/common/btn_browser_P.svg"
        shadowImage: "../../images/common/ombra_btn_browser.svg"
        defaultImage: "../../images/common/ico_elimina.svg"
        pressedImage: "../../images/common/ico_elimina_P.svg"
        status: 0
        onClicked: bg.visible = false
        anchors {
            top: bar.top
            topMargin: 6
            right: bar.right
            rightMargin: 10
        }
    }
}
