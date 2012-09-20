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

                BeepingMouseArea {
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
                onClicked: Stack.openPage("Rooms.qml")
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
                onClicked: Stack.openPage("Systems.qml")
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
                onClicked: Stack.openPage("Settings.qml")
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
                onClicked: Stack.openPage("Multimedia.qml")
                textMultimedia: qsTr ("multimedia")
            }
        }
    }
}
