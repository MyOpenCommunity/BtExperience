import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0 // a temporary workaround to load immediately the BtObjects module
import Components 1.0

BasePage {
    id: mainarea
    source: "images/home/home.jpg"

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    ListView {
        id: favourites
        model: favouritesModel
        delegate: favouritesDelegate
        orientation: ListView.Horizontal
        height: 130
        width: 150 * 6
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

        Component {
            id: favouritesDelegate

            Item {
                id: favouriteItem
                width: 150
                height: 130

                function bestDelegate(t) {
                    if (t === "camera")
                        return cameraDelegate
                    if (t === "web")
                        return webDelegate
                    return rssDelegate
                }

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

    CardView {
        ObjectModel {
            id: usersModel
            source: myHomeModels.profiles
        }

        id: users
        model: usersModel
        delegate: CardDelegate {
            property variant itemObject: usersModel.getObject(index)

            source: itemObject.image
            label: itemObject.description

            onClicked: Stack.openPage('Profile.qml', {'profile': itemObject})
        }
        anchors {
            top: toolbar.bottom
            topMargin: 50
            bottom: favourites.top
            left: parent.left
            leftMargin: 20
            right: pages.left
            rightMargin: 20
        }
    }

    MediaModel {
        source: myHomeModels.rooms
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
                    if (roomModel.count > 1)
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


