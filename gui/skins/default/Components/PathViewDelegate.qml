import QtQuick 1.1
import Components.Text 1.0
import BtExperience 1.0


Item {
    id: pathViewDelegate

    // this delegate needs an itemObject that defines image and description
    // properties
    property variant itemObject: undefined

    signal delegateClicked(variant delegate)

    width: bg.width
    height: bg.height

    Image { // placed here because the background must mask part of the image
        id: imageDelegate
        // the up-navigation is needed because images are referred to project
        // top folder
        source: "../" + itemObject.cardImageCached
        anchors {
            fill: bg
            topMargin: bg.height / 100 * 1.65
            leftMargin: bg.width / 100 * 1.98
            rightMargin: bg.width / 100 * 2.38
            bottomMargin: bg.height / 100 * 15.50
        }
    }

    Image {
        id: icon
        anchors.fill: imageDelegate
        Rectangle {
            id: bgProfilePressed
            color: "black"
            opacity: 0.5
            visible: false
            anchors.fill: parent
        }
    }

    SvgImage {
        id: bg

        source: global.guiSettings.skin === GuiSettings.Clear ?
                    "../images/profiles/scheda_profili.svg" :
                    "../images/profiles/scheda_profili_P.svg"

        Image
        {
            id: shadow_top
            y: -17
            width: 155
            height: 45
            anchors.left: parent.left
            anchors.leftMargin: 28
            source: "../images/profiles/ombra_schede/alto.png"
        }

        Image
        {
            id: shadow_top_left
            x: -17
            y: -17
            anchors.right: shadow_top.left
            anchors.rightMargin: 0
            source: "../images/profiles/ombra_schede/alto_sx.png"
        }

        Image
        {
            id: shadow_top_right
            y: -17
            anchors.left: shadow_top.right
            anchors.leftMargin: 0
            source: "../images/profiles/ombra_schede/alto_dx.png"
        }

        Image
        {
            id: shadow_left
            x: -17
            y: 28
            width: 45
            height: 250
            anchors.bottom: shadow_bottom.top
            anchors.bottomMargin: 0
            source: "../images/profiles/ombra_schede/sx.png"
        }

        Image
        {
            id: shadow_right
            x: 183
            width: 45
            height: 250
            anchors.top: shadow_top_right.bottom
            anchors.topMargin: 0
            source: "../images/profiles/ombra_schede/dx.png"
        }

        Image
        {
            id: shadow_buttom_left
            x: -17
            y: 278
            anchors.right: shadow_bottom.left
            anchors.rightMargin: 0
            source: "../images/profiles/ombra_schede/basso_sx.png"
        }

        Image
        {
            id: shadow_buttom_right
            x: 183
            anchors.top: shadow_right.bottom
            anchors.topMargin: 0
            source: "../images/profiles/ombra_schede/basso_dx.png"
        }

        Image
        {
            id: shadow_bottom
            x: 28
            y: 278
            width: 155
            height: 45
            anchors.right: shadow_buttom_right.left
            anchors.rightMargin: 0
            source: "../images/profiles/ombra_schede/basso.png"
        }
    }

    UbuntuLightText {
        id: textDelegate
        text: itemObject.description
        color: global.guiSettings.skin === GuiSettings.Clear ? "#434343" : "white"
        font.pixelSize: 18
        horizontalAlignment: Text.AlignHCenter
        anchors {
            bottom: bg.bottom
            bottomMargin: 10
            left: bg.left
            right: bg.right
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: pathViewDelegate.delegateClicked(itemObject)
        onPressed: pathViewDelegate.PathView.view.currentPressed = index
        onReleased: pathViewDelegate.PathView.view.currentPressed = -1
    }

    states: State {
        when: pathViewDelegate.PathView.view.currentPressed === index
        PropertyChanges {
            target: bg
            source: global.guiSettings.skin === GuiSettings.Clear ?
                        "../images/profiles/scheda_profili_P.svg" :
                        "../images/profiles/scheda_profili.svg"
        }
        PropertyChanges {
            target: textDelegate
            color: global.guiSettings.skin === GuiSettings.Clear ? "white" : "#434343"
        }
        PropertyChanges {
            target: bgProfilePressed
            visible: true
        }
    }
}
