import QtQuick 1.1
import BtObjects 1.0 // a temporary workaround to load immediately the BtObjects module
import BtExperience 1.0
import Components 1.0
import "js/Stack.js" as Stack
import "js/EventManager.js" as EventManager


BasePage {
    id: mainarea

    source : global.guiSettings.skin === GuiSettings.Clear ? "images/home/home.jpg" :
                                                             "images/home/home_dark.jpg"

    Rectangle {
        z: 1
        anchors.fill: parent
        color: "silver"
        opacity: 0.6
        visible: EventManager.eventManager.scenarioRecording
        MouseArea {
            anchors.fill: parent
        }
    }

    ToolBar {
        id: toolbar
        z: 2
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    ConfirmationBar {
        id: scenarioBar

        height: 45
        z: 2
        opacity: EventManager.eventManager.scenarioRecording ? 1.0 : 0.0
        anchors {
            top: toolbar.bottom
            topMargin: -12
            left: parent.left
            right: parent.right
        }
    }

    MediaModel {
        id: homeLinksModel
        source: myHomeModels.mediaLinks
        containers: myHomeModels.homepageLinks ? [myHomeModels.homepageLinks.uii] : [Container.IdNoContainer]
    }

    ListView {
        id: favourites
        model: homeLinksModel
        delegate: favouritesDelegate
        orientation: ListView.Horizontal
        height: 130
        width: 140 * 7
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        interactive: false

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

                property variant itemObject: homeLinksModel.getObject(index)

                width: 140
                height: 130

                function bestDelegate(t) {
                    if (t === LinkInterface.Camera)
                        return cameraDelegate
                    if (t === LinkInterface.Web)
                        return webDelegate
                    return rssDelegate
                }

                Loader {
                    id: favouriteItemLoader
                    sourceComponent: bestDelegate(itemObject.type)
                    anchors.centerIn: favouriteItem
                    z: 1
                    onLoaded: item.itemObject = favouriteItem.itemObject
                }
            }
        }
    }

    ObjectModel {
        id: profilesModel
        source: myHomeModels.profiles
    }

    ControlPathView {
        id: pathView
        visible: model.count >= 3
        model: profilesModel
        anchors {
            bottom: favourites.top
            top: toolbar.bottom
            left: parent.left
            leftMargin: 10
            right: homeMenu.left
            rightMargin: -10
        }
        pathOffset: model.count === 4 ? -35 : (model.count === 6 ? -33 : 0)
        arrowsMargin: model.count === 4 ? 30 : (model.count === 6 ? 15 : 10)
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
            source: itemObject.cardImageCached
            label: itemObject.description

            onClicked: Stack.goToPage('Profile.qml', {'profile': itemObject})
        }

        delegateSpacing: 40
        visibleElements: 2

        model: profilesModel
    }

    Item {
        id: homeMenu
        width: menu_bg.width
        height: menu_bg.height
        z: 2

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
                anchors.rightMargin: width / 100 * 16
                anchors.right: system.left
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
                enabled: EventManager.eventManager.scenarioRecording === false
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
                enabled: EventManager.eventManager.scenarioRecording === false
            }
        }
    }
}
