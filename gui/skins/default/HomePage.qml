import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0 // a temporary workaround to load immediately the BtObjects module
import Components 1.0

Page {
    id: mainarea
    source: "images/home/home.jpg"

    function bestDelegate(t) {
        if (t === "camera")
            return cameraDelegate
        if (t === "web")
            return webDelegate
        return rssDelegate
    }

    Component {
        id: cameraDelegate
        CameraLink {}
    }

    Component {
        id: webDelegate
        FavoriteItem {}
    }

    Component {
        id: rssDelegate
        RssItem {}
    }

    ToolBar {
        id: toolbar
        onExitClicked: console.log("exit")
        fontFamily: semiBoldFont.name
        fontSize: 17
    }

    ListView {
        id: favourites
        model: favouritesModel
        delegate: favouritesDelegate
        orientation: ListView.Horizontal
        height: 130
        width: 170 * 6
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        interactive: false

        ListModel {
            id: favouritesModel
            ListElement {
                type: "camera"
                address: ""
                name: "Cancelletto"
            }
            ListElement {
                type: "web"
                address: "http://www.corriere.it"
                name: "Corriere.it"
            }
            ListElement {
                type: "web"
                address: "http://www.gazzetta.it"
                name: "Gazzetta.it"
            }
            ListElement {
                type: "web"
                address: "http://www.repubblica.it"
                name: "Repubblica.it"
            }
            ListElement {
                type: "web"
                address: "http://www.style.it"
                name: "Style.it"
            }
            ListElement {
                type: "rss"
                address: "http://www.corriere.it"
                name: "News Corriere.it"
            }
        }

        Component {
            id: favouritesDelegate

            Item {
                id: favouriteItem
                width: 170
                height: 130
                Loader {
                    id: favouriteItemLoader
                    sourceComponent: bestDelegate(type)
                    anchors.centerIn: favouriteItem
                    z: 1
                    Component.onCompleted: {
                        item.editable = false
                    }
                    onLoaded: {
                        item.text = model.name
                        item.address = model.address
                    }
                }
            }
        }
    }

    PathView {
        ListModel {
            id: usersModel
            ListElement {
                image: "images/home/card_1.png"
                name: "famiglia"
            }
            ListElement {
                image: "images/home/card_2.png"
                name: "mattia"
            }
            ListElement {
                image: "images/home/card_3.png"
                name: "camilla"
            }
            ListElement {
                image: "images/home/card_4.png"
                name: "mamma"
            }
            ListElement {
                image: "images/home/card_5.png"
                name: "papà"
            }
        }

        Component {
            id: usersDelegate
            Item {
                id: itemDelegate
                width: imageDelegate.sourceSize.width
                height: imageDelegate.sourceSize.height + textDelegate.height

                z: PathView.z
                scale: PathView.iconScale + 0.1

                Image {
                    id: imageDelegate
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    source: image
                }

                Text {
                    id: textDelegate
                    text: name
                    font.family: regularFont.name
                    font.pixelSize: 22
                    anchors.top: imageDelegate.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignHCenter
                }

                SvgImage {
                    id: rectPressed
                    source: "images/common/profilo_p.svg"
                    visible: false
                    anchors {
                        centerIn: imageDelegate
                        fill: imageDelegate
                        margins: 20
                    }
                    width: imageDelegate.width
                    height: imageDelegate.height
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: Stack.openPage('Profile.qml', {'profile': name, 'sourceImage': image})
                    onPressed: itemDelegate.PathView.view.currentPressed = index
                    onReleased: itemDelegate.PathView.view.currentPressed = -1
                }

                states: State {
                    when: itemDelegate.PathView.view.currentPressed === index
                    PropertyChanges {
                        target: rectPressed
                        visible: true
                    }
                }
            }
        }

        id: users
        property int currentPressed: -1
        model: usersModel
        delegate: usersDelegate

        path:  Path {
            startX: 100; startY: 250
            PathAttribute { name: "iconScale"; value: 0.4 }
            PathAttribute { name: "z"; value: 0.1 }
            PathLine { x: 160; y: 250; }
            PathAttribute { name: "iconScale"; value: 0.5 }
            PathLine { x: 310; y: 210; }
            PathAttribute { name: "iconScale"; value: 1.0 }
            PathAttribute { name: "z"; value: 1.0 }
            PathLine { x: 420; y: 243; }
            PathAttribute { name: "iconScale"; value: 0.6 }
            PathLine { x: 560; y: 252; }
            PathAttribute { name: "iconScale"; value: 0.35 }
            PathLine { x: 630; y: 250; }
        }
        width: 620
        pathItemCount: 5
        anchors.bottom: favourites.top
        anchors.bottomMargin: 0
        anchors.top: toolbar.bottom
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        onFlickStarted: currentPressed = -1
        onMovementEnded: currentPressed = -1
    }

    RoomListModel {
        id: roomModel
    }

    Item {
        id: pages
        x: 620
        y: 65
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: users.right
        anchors.leftMargin: 0
        anchors.bottom: favourites.top
        anchors.bottomMargin: 0
        anchors.top: toolbar.bottom
        anchors.topMargin: 0

        SvgImage {
            source: "images/home/menu.svg"
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -30
            anchors.right: parent.right
            anchors.rightMargin: 30
        }
        Grid {
            id: column1
            x: -288
            y: 70
            spacing: 0
            columns: 2
            anchors.top: parent.top
            anchors.topMargin: 70
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            width: 288
            height: 328

            ButtonHomePageLink {
                textFirst: false
                source: "images/home/stanze.svg"
                sourcePressed: "images/home/stanze_p.svg"
                text: qsTr("rooms")
                onClicked: {
                    if (roomModel.rooms().length > 1)
                        Stack.openPage("Rooms.qml")
                    else
                        Stack.openPage("Room.qml")
                }
            }

            ButtonHomePageLink {
                textFirst: false
                source: "images/home/sistemi.svg"
                sourcePressed: "images/home/sistemi_p.svg"
                text: qsTr("systems")
                onClicked: Stack.openPage("Systems.qml")
            }

            ButtonHomePageLink {
                source: "images/home/opzioni.svg"
                sourcePressed: "images/home/opzioni_p.svg"
                text: qsTr("options")
                onClicked: Stack.openPage("Settings.qml")
            }

            ButtonHomePageLink {
                source: "images/home/multimedia.svg"
                sourcePressed: "images/home/multimedia_p.svg"
                text: qsTr("multimedia")
                onClicked: Stack.openPage("Browser.qml")
            }
        }
    }
}


