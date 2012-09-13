import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0 // a temporary workaround to load immediately the BtObjects module
import Components 1.0
import Components.Text 1.0

BasePage {
    id: mainarea
    source : global.guiSettings.skin === 0 ? "images/home/home.bmp" :
                                             "images/home/home_dark.jpg"

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
                    }
                }
            }
        }
    }

    ObjectModel {
        id: usersModel
        source: myHomeModels.profiles
    }

    ControlPathView {
        visible: model.count >= 3
        model: usersModel
        width: 740
        anchors {
            bottom: favourites.top
            top: toolbar.bottom
            left: parent.left
        }
        onClicked: Stack.openPage('Profile.qml', {'profile': delegate})
    }

    Item { // needed to properly center the CardView
        anchors {
            bottom: favourites.top
            top: toolbar.bottom
            left: parent.left
            right: parent.right
        }
        CardView {
            visible: model.count < 3
            delegate: CardDelegate {
                property variant itemObject: usersModel.getObject(index)
                source: itemObject.image
                label: itemObject.description

                onClicked: Stack.openPage('Profile.qml', {'profile': itemObject})
            }

            delegateSpacing: 40
            visibleElements: 2

            model: usersModel
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -140
        }
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
                source: global.guiSettings.skin === 0 ? "images/home/home_menu_bg_top_left.svg" :
                                                        "images/home/home_menu_bg_top_left_pressed.svg"
                sourcePressed: global.guiSettings.skin === 0 ? "images/home/home_menu_bg_top_left_pressed.svg" :
                                                               "images/home/home_menu_bg_top_left.svg"
                icon: "images/home/home_menu_icon_rooms.svg"
                text: qsTr("rooms")
                onClicked: Stack.openPage("Rooms.qml")
            }

            ButtonHomePageLink {
                source: global.guiSettings.skin === 0 ? "images/home/home_menu_bg_top_right.svg" :
                                                        "images/home/home_menu_bg_top_right_pressed.svg"
                sourcePressed: global.guiSettings.skin === 0 ? "images/home/home_menu_bg_top_right_pressed.svg" :
                                                               "images/home/home_menu_bg_top_right.svg"
                icon: "images/home/home_menu_icon_systems.svg"
                text: qsTr("systems")
                onClicked: Stack.openPage("Systems.qml")
            }

            ButtonHomePageLink {
                source: global.guiSettings.skin === 0 ? "images/home/home_menu_bg_bottom_left.svg" :
                                                        "images/home/home_menu_bg_bottom_left_pressed.svg"
                sourcePressed: global.guiSettings.skin === 0 ? "images/home/home_menu_bg_bottom_left_pressed.svg" :
                                                               "images/home/home_menu_bg_bottom_left.svg"
                icon: "images/home/home_menu_icon_options.svg"
                text: qsTr("options")
                onClicked: Stack.openPage("Settings.qml")
            }

            ButtonHomePageLink {
                source: global.guiSettings.skin === 0 ? "images/home/home_menu_bg_bottom_right.svg":
                                                        "images/home/home_menu_bg_bottom_right_pressed.svg"
                sourcePressed: global.guiSettings.skin === 0 ? "images/home/home_menu_bg_bottom_right_pressed.svg" :
                                                               "images/home/home_menu_bg_bottom_right.svg"
                icon: "images/home/home_menu_icon_multimedia.svg"
                text: qsTr("multimedia")
                onClicked: Stack.openPage("Multimedia.qml")
            }
        }
    }
}
