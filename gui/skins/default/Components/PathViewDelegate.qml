import QtQuick 1.1
import Components.Text 1.0


Item {
    id: pathViewDelegate

    // this delegate needs an itemObject that defines image and description
    // properties
    property variant itemObject: undefined

    signal delegateClicked

    width: imageDelegate.sourceSize.width
    height: imageDelegate.sourceSize.height + textDelegate.height

    Image {
        id: imageDelegate
        source: "../" + itemObject.image
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    UbuntuLightText {
        id: textDelegate
        text: itemObject.description
        font.pixelSize: 22
        horizontalAlignment: Text.AlignHCenter
        anchors {
            top: imageDelegate.bottom
            left: parent.left
            right: parent.right
            topMargin: 8
        }
    }

    SvgImage {
        id: rectPressed
        source: global.guiSettings.skin === 0 ? "../images/common/profilo_p.svg" :
                                                "../images/home_dark/home.jpg"
        visible: false
        width: imageDelegate.width
        height: imageDelegate.height
        anchors {
            centerIn: imageDelegate
            fill: imageDelegate
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: pathViewDelegate.delegateClicked()
        onPressed: pathViewDelegate.PathView.view.currentPressed = index
        onReleased: pathViewDelegate.PathView.view.currentPressed = -1
    }

    states: State {
        when: pathViewDelegate.PathView.view.currentPressed === index
        PropertyChanges {
            target: rectPressed
            visible: true
        }
    }
}
