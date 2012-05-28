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
                        item.color = "black"
                    }
                }
            }
        }
    }

    ListView {
        id: users
        property int currentPressed: -1
        model: usersModel
        delegate: usersDelegate
        orientation: ListView.Horizontal
        spacing: 2
        clip: true
        height: 300

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: pages.left
        }
        onFlickStarted: currentPressed = -1
        onMovementEnded: currentPressed = -1

        ListModel {
            id: usersModel
//            ListElement {
//                image: "images/home/card_1.png"
//                name: "famiglia"
//            }
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
                width: delegateBackground.width
                height: delegateBackground.height + delegateShadow.height

                Rectangle {
                    id: textDelegate
                    width: 175
                    height: 20
                    color: Qt.rgba(230, 230, 230)
                    opacity: 0.5
                    Text {
                        text: name
                        font.family: regularFont.name
                        font.pixelSize: 15
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    id: delegateBackground
                    width: 175
                    height: 244
                    anchors.top: textDelegate.bottom
                    color: Qt.rgba(230, 230, 230)
                    opacity: 0.5
                }

                Image {
                    id: imageDelegate
                    width: 169
                    height: 238
                    anchors { bottom: delegateBackground.bottom; bottomMargin: 5 }
                    source: image
                }

                SvgImage {
                    id: delegateShadow
                    source: "images/home/pager_shadow.svg"
                    anchors {
                        top: delegateBackground.bottom
                        topMargin: 5
                        horizontalCenter: delegateBackground.horizontalCenter
                    }
                }

                SvgImage {
                    id: rectPressed
                    source: "images/common/profilo_p.svg"
                    visible: false
                    anchors {
                        fill: imageDelegate
                        // FIXME: currently, profile images have a transparent
                        // border around them, so we need the margins here
                        margins: 15
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: Stack.openPage('Profile.qml', {'profile': name, 'sourceImage': image})
                    onPressed: itemDelegate.ListView.view.currentPressed = index
                    onReleased: itemDelegate.ListView.view.currentPressed = -1
                }

                states: State {
                    when: itemDelegate.ListView.view.currentPressed === index
                    PropertyChanges {
                        target: rectPressed
                        visible: true
                    }
                }
            }
        }
    }

    RoomListModel {
        id: roomModel
    }

    Item {
        id: pages
        anchors.right: parent.right
        anchors.bottom: favourites.top
        anchors.top: toolbar.bottom
        width: 288

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
            spacing: 0
            columns: 2
            anchors.top: parent.top
            anchors.topMargin: 70
            anchors.bottom: parent.bottom
            anchors.right: parent.right
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
                onClicked: Stack.openPage("Multimedia.qml")
            }
        }
    }
}


