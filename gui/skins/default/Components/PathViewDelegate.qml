import QtQuick 1.1
import BtObjects 1.0
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
        source: itemObject.cardImageCached[0] === "/" ?
                    itemObject.cardImageCached :
                    "../" + itemObject.cardImageCached
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

        source: homeProperties.skin === HomeProperties.Clear ?
                    "../images/profiles/scheda_profili.svg" :
                    "../images/profiles/scheda_profili_P.svg"
    }

    BorderImage {
        id: cardShadow
        source: "../images/profiles/card_shadow.png"
        anchors.centerIn: bg
        width: 238
        height: 331
        border { left: 24; top: 22; right: 24; bottom: 22 }
        horizontalTileMode: BorderImage.Stretch
        verticalTileMode: BorderImage.Stretch
    }

    UbuntuLightText {
        id: textDelegate
        text: itemObject.description
        color: homeProperties.skin === HomeProperties.Clear ? "#434343" : "white"
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        anchors {
            bottom: bg.bottom
            bottomMargin: 15
            left: bg.left
            leftMargin: 8
            right: bg.right
            rightMargin: 8
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
            source: homeProperties.skin === HomeProperties.Clear ?
                        "../images/profiles/scheda_profili_P.svg" :
                        "../images/profiles/scheda_profili.svg"
        }
        PropertyChanges {
            target: textDelegate
            color: homeProperties.skin === HomeProperties.Clear ? "white" : "#434343"
        }
        PropertyChanges {
            target: bgProfilePressed
            visible: true
        }
    }
}
