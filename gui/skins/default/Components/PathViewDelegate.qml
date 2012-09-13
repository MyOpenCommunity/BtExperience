import QtQuick 1.1
import Components.Text 1.0


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
        source: "../" + itemObject.image
        anchors.fill: bg
    }

    SvgImage {
        id: bg

        source: global.guiSettings.skin === 0 ?
                    "../images/profiles/scheda_profili.svg" :
                    "../images/profiles/scheda_profili_dark.svg"
    }

    UbuntuLightText {
        id: textDelegate
        text: itemObject.description
        color: "#434343"
        font.pixelSize: 14
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
            source: global.guiSettings.skin === 0 ?
                        "../images/profiles/scheda_profili_P.svg" :
                        "../images/profiles/scheda_profili_dark_P.svg"
        }
    }
}
