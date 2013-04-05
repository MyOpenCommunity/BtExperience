import QtQuick 1.1
import BtObjects 1.0 // a temporary workaround to load immediately the BtObjects module
import BtExperience 1.0
import Components 1.0
import "js/Stack.js" as Stack
import "js/EventManager.js" as EventManager


/**
  \ingroup Core

  \brief The QML Home page.

  This page implements the home page for the entire application. The HomePage
  contains a Toolbar on the top.
  */
BasePage {
    id: mainarea

    property alias helpUrl: toolbar.helpUrl

    source : homeProperties.homeBgImage

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

    MediaModel {
        id: roomModel
        source: myHomeModels.rooms
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
            id: scenarioDelegate
            ScenarioLink { pageObject: mainarea }
        }

        Component {
            id: webDelegate
            FavoriteItem {
                onClicked: mainarea.processLaunched(global.browser)
            }
        }

        Component {
            id: rssDelegate
            RssItem {}
        }

        Component {
            id: meteoDelegate
            MeteoItem {}
        }

        Component {
            id: webRadioDelegate
            WebRadioLink {}
        }

        Component {
            id: webcamDelegate
            WebcamLink {}
        }

        Component {
            id: favouritesDelegate

            Item {
                id: favouriteItem

                property variant itemObject: homeLinksModel.getObject(index)

                width: 140
                height: 130

                function bestDelegate(t) {
                    switch (t) {
                    case LinkInterface.Camera:
                        return cameraDelegate
                    case LinkInterface.Web:
                        return webDelegate
                    case MediaLink.Webcam:
                        return webcamDelegate
                    case LinkInterface.WebRadio:
                        return webRadioDelegate
                    case MediaLink.Scenario:
                        return scenarioDelegate
                    case MediaLink.Rss:
                        return rssDelegate
                    default:
                        return meteoDelegate
                    }
                }

                Loader {
                    id: favouriteItemLoader
                    sourceComponent: bestDelegate(itemObject.type)
                    anchors.centerIn: favouriteItem
                    z: 1
                    onLoaded: {
                        item.itemObject = favouriteItem.itemObject
                        item.editable = false
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

        Column {
            id: rightColumn
            anchors {
                verticalCenter: menu_bg.verticalCenter
                right: leftColumn.left
                rightMargin: 11
            }

            spacing: menu_bg.height / 100 * 1.5

            ButtonHomePageLink {
                id: room
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: -3
                }
                textVerticalOffset: width / 100 * 45

                visible: roomModel.count > 0

                source: homeProperties.skin === HomeProperties.Clear ? "images/home/btn_stanze.svg" :
                                                                        "images/home/btn_stanze_P.svg"
                sourcePressed: homeProperties.skin === HomeProperties.Clear ? "images/home/btn_stanze_P.svg" :
                                                                               "images/home/btn_stanze.svg"
                icon: homeProperties.skin === HomeProperties.Clear ? "images/home/ico_stanze.svg" :
                                                                      "images/home/ico_stanze_P.svg"
                iconPressed: homeProperties.skin === HomeProperties.Clear ? "images/home/ico_stanze_P.svg" :
                                                                             "images/home/ico_stanze.svg"
                text: qsTr("rooms")
                onTouched: Stack.goToPage("Rooms.qml")
            }

            ButtonHomePageLink {
                id: option
                textVerticalOffset: -width / 100 * 45
                source: homeProperties.skin === HomeProperties.Clear ? "images/home/btn_opzioni.svg" :
                                                                        "images/home/btn_opzioni_P.svg"
                sourcePressed: homeProperties.skin === HomeProperties.Clear ? "images/home/btn_opzioni_P.svg" :
                                                                               "images/home/btn_opzioni.svg"
                icon: homeProperties.skin === HomeProperties.Clear ? "images/home/ico_opzioni.svg" :
                                                                      "images/home/ico_opzioni_P.svg"
                iconPressed: homeProperties.skin === HomeProperties.Clear ? "images/home/ico_opzioni_P.svg" :
                                                                             "images/home/ico_opzioni.svg"
                onTouched: Stack.goToPage("Settings.qml")
                text: qsTr("settings")
                enabled: EventManager.eventManager.scenarioRecording === false
            }
        }

        Column {
            id:leftColumn
            anchors {
                verticalCenter: menu_bg.verticalCenter
                horizontalCenter: menu_bg.horizontalCenter
                horizontalCenterOffset: leftColumn.width / 2
            }

            spacing: menu_bg.height / 100 * 1.5

            ButtonHomePageLink {
                id: system
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: 3
                }
                textVerticalOffset: width / 100 * 45
                source: homeProperties.skin === HomeProperties.Clear ? "images/home/btn_sistemi.svg" :
                                                                        "images/home/btn_sistemi_P.svg"
                sourcePressed: homeProperties.skin === HomeProperties.Clear ? "images/home/btn_sistemi_P.svg" :
                                                                               "images/home/btn_sistemi.svg"
                icon: homeProperties.skin === HomeProperties.Clear ? "images/home/ico_sistemi.svg" :
                                                                      "images/home/ico_sistemi_P.svg"
                iconPressed: homeProperties.skin === HomeProperties.Clear ? "images/home/ico_sistemi_P.svg" :
                                                                             "images/home/ico_sistemi.svg"
                text: qsTr("functions")
                onTouched: Stack.goToPage("Systems.qml")
            }

            ButtonHomePageLink {
                id: multimedia
                textVerticalOffset: -width / 100 * 45

                source: homeProperties.skin === HomeProperties.Clear ? "images/home/btn_multimedia.svg" :
                                                                        "images/home/btn_multimedia_P.svg"
                sourcePressed: homeProperties.skin === HomeProperties.Clear ? "images/home/btn_multimedia_P.svg" :
                                                                               "images/home/btn_multimedia.svg"
                icon: homeProperties.skin === HomeProperties.Clear ? "images/home/ico_multimedia.svg" :
                                                                      "images/home/ico_multimedia_P.svg"
                iconPressed: homeProperties.skin === HomeProperties.Clear ? "images/home/ico_multimedia_P.svg" :
                                                                             "images/home/ico_multimedia.svg"
                onTouched: Stack.goToPage("Multimedia.qml")
                text: qsTr ("multimedia")
                enabled: EventManager.eventManager.scenarioRecording === false
            }
        }
    }
}
