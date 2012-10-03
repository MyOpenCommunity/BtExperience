import QtQuick 1.1
import "js/Stack.js" as Stack
import BtObjects 1.0 // a temporary workaround to load immediately the BtObjects module
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0

BasePage {
    id: mainarea
    source : global.guiSettings.skin === GuiSettings.Clear ? "images/home/home.jpg" :
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
                        item.itemObject = model
                    }
                }
            }
        }
    }

    ObjectModel {
        id: profilesModel
        source: myHomeModels.profiles
    }

    ControlPathView {
        visible: model.count >= 3
        model: profilesModel
        width: 740
        anchors {
            bottom: favourites.top
            top: toolbar.bottom
            left: parent.left
        }
        onClicked: Stack.goToPage('Profile.qml', {'profile': delegate})
    }

    CardView {
        anchors { // we need a little different anchoring here to center the CardView
            bottom: favourites.top
            top: toolbar.bottom
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: -140
        }
        visible: model.count < 3
        delegate: CardDelegate {
            property variant itemObject: profilesModel.getObject(index)
            source: itemObject.image
            label: itemObject.description

            onClicked: Stack.goToPage('Profile.qml', {'profile': itemObject})
        }

        delegateSpacing: 40
        visibleElements: 2

        model: profilesModel
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
            rightMargin: parent.width / 100 * 4
            bottom: favourites.top
            top: toolbar.bottom
            topMargin: parent.height / 100 * 7
        }

        SvgImage {
            id: menu_bg
            source: "images/home/home_menu_bg_shadow.svg"
        }

        Grid {
            id: grid1
            anchors.centerIn: menu_bg
            spacing: menu_bg.height / 100 * 1.5
            columns: 2

            ButtonHomePageLink {
                id: room
                anchors.right: system.left
                anchors.rightMargin: width / 100 * 16
                source: global.guiSettings.skin === GuiSettings.Clear ? "images/home/btn_stanze.svg" :
                                                                        "images/home/btn_stanze_P.svg"
                sourcePressed: global.guiSettings.skin === GuiSettings.Clear ? "images/home/btn_stanze_P.svg" :
                                                                               "images/home/btn_stanze.svg"
                icon: global.guiSettings.skin === GuiSettings.Clear ? "images/home/ico_stanze.svg" :
                                                                      "images/home/ico_stanze_P.svg"
                iconPressed: global.guiSettings.skin === GuiSettings.Clear ? "images/home/ico_stanze_P.svg" :
                                                                             "images/home/ico_stanze.svg"
                text: qsTr("rooms")
                onClicked: Stack.goToPage("Rooms.qml")
            }

            ButtonHomePageLink {
                id: system
                anchors.right: parent.right
                source: global.guiSettings.skin === GuiSettings.Clear ? "images/home/btn_sistemi.svg" :
                                                                        "images/home/btn_sistemi_P.svg"
                sourcePressed: global.guiSettings.skin === GuiSettings.Clear ? "images/home/btn_sistemi_P.svg" :
                                                                               "images/home/btn_sistemi.svg"
                icon: global.guiSettings.skin === GuiSettings.Clear ? "images/home/ico_sistemi.svg" :
                                                                      "images/home/ico_sistemi_P.svg"
                iconPressed: global.guiSettings.skin === GuiSettings.Clear ? "images/home/ico_sistemi_P.svg" :
                                                                             "images/home/ico_sistemi.svg"
                textSystem: qsTr("systems")
                onClicked: Stack.goToPage("Systems.qml")
            }

            ButtonHomePageLink {
                id: option
                anchors.right: multimedia.left
                anchors.rightMargin: width / 100 * 10
                source: global.guiSettings.skin === GuiSettings.Clear ? "images/home/btn_opzioni.svg" :
                                                                        "images/home/btn_opzioni_P.svg"
                sourcePressed: global.guiSettings.skin === GuiSettings.Clear ? "images/home/btn_opzioni_P.svg" :
                                                                               "images/home/btn_opzioni.svg"
                icon: global.guiSettings.skin === GuiSettings.Clear ? "images/home/ico_opzioni.svg" :
                                                                      "images/home/ico_opzioni_P.svg"
                iconPressed: global.guiSettings.skin === GuiSettings.Clear ? "images/home/ico_opzioni_P.svg" :
                                                                             "images/home/ico_opzioni.svg"
                onClicked: Stack.goToPage("Settings.qml")
                textOption: qsTr("otpions")
            }

            ButtonHomePageLink {
                id: multimedia
                anchors.right: parent.right
                anchors.rightMargin: parent.height / 100 * 1.1
                source: global.guiSettings.skin === GuiSettings.Clear ? "images/home/btn_multimedia.svg" :
                                                                        "images/home/btn_multimedia_P.svg"
                sourcePressed: global.guiSettings.skin === GuiSettings.Clear ? "images/home/btn_multimedia_P.svg" :
                                                                               "images/home/btn_multimedia.svg"
                icon: global.guiSettings.skin === GuiSettings.Clear ? "images/home/ico_multimedia.svg" :
                                                                      "images/home/ico_multimedia_P.svg"
                iconPressed: global.guiSettings.skin === GuiSettings.Clear ? "images/home/ico_multimedia_P.svg" :
                                                                             "images/home/ico_multimedia.svg"
                onClicked: Stack.goToPage("Multimedia.qml")
                textMultimedia: qsTr ("multimedia")
            }
        }
    }
}
