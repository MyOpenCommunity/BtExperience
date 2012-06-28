import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0 // a temporary workaround to load immediately the BtObjects module
import Components 1.0
import Components.Text 1.0

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
        onHomeClicked: Stack.openPage("NewProfileCard.qml")
    }

    ListView {
        id: favourites
        model: favouritesModel
        delegate: favouritesDelegate
        orientation: ListView.Horizontal
        height: 130
        width: 140 * 7
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
            ListElement {
                type: "web"
                address: "http://www.bticino.it"
                name: "BTicino.it"
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
                width: 140
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

    PathView {
        ObjectModel {
            id: usersModel
            source: myHomeModels.profiles
        }

        Component {
            id: usersDelegate
            Item {
                id: itemDelegate
                property variant itemObject: usersModel.getObject(index)
                width: imageDelegate.sourceSize.width
                height: imageDelegate.sourceSize.height + textDelegate.height

                z: PathView.z
                scale: PathView.iconScale + 0.1

                Image {
                    id: imageDelegate
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    source: itemObject.image
                }

                UbuntuLightText {
                    id: textDelegate
                    text: itemObject.description
                    font.pixelSize: 22
                    anchors.top: imageDelegate.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 8
                    horizontalAlignment: Text.AlignHCenter
                }

                //Component.onCompleted: {
                //console.log('icon scale: ' + PathView.iconScale + ' x:' + itemDelegate.x)
                //}

                SvgImage {
                    id: rectPressed
                    source: "images/common/profilo_p.svg"
                    visible: false
                    anchors {
                        centerIn: imageDelegate
                        fill: imageDelegate
                    }
                    width: imageDelegate.width
                    height: imageDelegate.height
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Stack.openPage('Profile.qml', {'profile': itemDelegate.itemObject})
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

    MediaModel {
        source: myHomeModels.rooms
        id: roomModel
    }

    Item {
        id: homeMenu
        width: menu_bg.width
        height: menu_bg.height

        anchors {
            right: parent.right
            rightMargin: parent.width / 100 * 1.3
            bottom: favourites.top
            top: parent.top
            topMargin: parent.height / 100 * 20
        }

        SvgImage {
            id: menu_bg
            source: "images/home/home_menu_bg_shadow.svg"
        }
        Grid {
            anchors.fill: menu_bg
            spacing: 5
            columns: 2
            ButtonHomePageLink {
                source: "images/home/home_menu_bg_top_left.svg"
                sourcePressed: "images/home/home_menu_bg_top_left_pressed.svg"
                icon: "images/home/home_menu_icon_rooms.svg"
                text: qsTr("rooms")
                onClicked: {
                    if (roomModel.count > 1)
                        Stack.openPage("Rooms.qml")
                    else
                        Stack.openPage("Room.qml")
                }
            }

            ButtonHomePageLink {
                source: "images/home/home_menu_bg_top_right.svg"
                sourcePressed: "images/home/home_menu_bg_top_right_pressed.svg"
                icon: "images/home/home_menu_icon_systems.svg"
                text: qsTr("systems")
                onClicked: Stack.openPage("Systems.qml")
            }

            ButtonHomePageLink {
                source: "images/home/home_menu_bg_bottom_left.svg"
                sourcePressed: "images/home/home_menu_bg_bottom_left_pressed.svg"
                icon: "images/home/home_menu_icon_options.svg"
                text: qsTr("options")
                onClicked: Stack.openPage("Settings.qml")
            }

            ButtonHomePageLink {
                source: "images/home/home_menu_bg_bottom_right.svg"
                sourcePressed: "images/home/home_menu_bg_bottom_right_pressed.svg"
                icon: "images/home/home_menu_icon_multimedia.svg"
                text: qsTr("multimedia")
                onClicked: Stack.openPage("Multimedia.qml")
            }
        }
    }
}
