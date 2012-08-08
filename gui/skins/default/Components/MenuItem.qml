import QtQuick 1.1
import Components.Text 1.0


Item {
    id: menuItem
    height: background.height
    width: background.width

    property bool isSelected: false
    property bool editable: false
    property string name
    property alias description: textDescription.text
    property alias boxInfoState: boxInfo.state
    property alias boxInfoText: boxInfoText.text
    property int status: -1
    property bool hasChild: false
    property alias backgroundImage: background.source

    signal clicked(variant itemClicked)
    signal pressed(variant itemPressed)
    signal released(variant itemReleased)
    signal editCompleted()

    QtObject {
        id: privateProps

        function startEdit() {
            labelLoader.sourceComponent = labelInputComponent
            labelLoader.item.forceActiveFocus()
            labelLoader.item.openSoftwareInputPanel()
        }

        function editDone() {
            if (labelLoader.item.text !== menuItem.name) {
                menuItem.name = labelLoader.item.text
                menuItem.editCompleted()
            }
            labelLoader.sourceComponent = labelComponent
        }
    }

    function statusVisible() {
        return menuItem.status > -1
    }

    function iconStatusImage() {
        if (!statusVisible())
            return ""
        var base = "../images/common/"
        if (menuItem.status === 0)
            return base + "menu_column_item_inactive_led.svg"
        else if (menuItem.status === 1)
            return base + "menu_column_item_active_led.svg"
        else if (menuItem.status === 2)
            return base + "menu_column_item_warning_led.svg"
        else if (menuItem.status === 3)
            return base + "menu_column_item_alarm_led.svg"
    }

    SvgImage {
        anchors.fill: parent
        id: background
        source: "../images/common/menu_column_item_bg.svg";
    }


    Item {
        anchors.fill: parent

        SvgImage {
            id: iconStatus
            source: iconStatusImage()
            anchors.left: parent.left
            anchors.leftMargin: menuItem.width / 100 * 2
            anchors.topMargin: menuItem.height / 100 * 18
            anchors.top: parent.top
        }

        Loader {
            id: labelLoader
            property color textColor: "#2d2d2d"
            anchors.left: parent.left
            anchors.leftMargin: menuItem.width / 100 * 9
            anchors.top: parent.top
            anchors.topMargin: menuItem.height / 100 * 16
            anchors.right: arrowRight.left
            sourceComponent: labelComponent
        }

        Component {
            id: labelInputComponent
            UbuntuMediumTextInput {
                text: menuItem.name
                activeFocusOnPress: false
                font.pixelSize: 13
                color: labelLoader.textColor
                onActiveFocusChanged: if (!activeFocus) { privateProps.editDone() }
            }
        }

        Component {
            id: labelComponent
            UbuntuMediumText {
                text: menuItem.name
                font.pixelSize: 13
                color:  labelLoader.textColor
                elide: Text.ElideRight
            }
        }

        Image {
            visible: menuItem.hasChild
            id: arrowRight
            source: "../images/common/menu_column_item_arrow.svg"
            anchors.right: parent.right
            anchors.rightMargin: menuItem.width / 100 * 3
            anchors.top: parent.top
            anchors.topMargin: menuItem.height / 100 * 24
        }

        Item {
            id: boxInfo
            visible: false
            anchors.top: labelLoader.bottom
            anchors.bottom: parent.bottom
            anchors.left: labelLoader.left
            width: 45

            Rectangle {
                id: boxInfoRect
                color: "#999"
                radius: 4
                height: 17
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right

                UbuntuLightText {
                    id: boxInfoText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    font.pixelSize: 13
                }
            }

            states: [
                State {
                    name: "info"
                    PropertyChanges { target: boxInfoRect; color: "#999999" }
                    PropertyChanges { target: boxInfo; visible: true }

                },
                State {
                    name: "warning"
                    PropertyChanges { target: boxInfoRect; color: "#ed1b35" }
                    PropertyChanges { target: boxInfo; visible: true }
                }
            ]
        }

        UbuntuLightText {
            id: textDescription
            color: "#626262"
            wrapMode: Text.NoWrap
            font.pixelSize: 13
            anchors.bottom: parent.bottom
            anchors.bottomMargin: menuItem.height / 100 * 10
            anchors.top: labelLoader.bottom
            anchors.left: boxInfo.visible ? boxInfo.right : labelLoader.left
            anchors.leftMargin: boxInfo.visible ? 5 : 0
            verticalAlignment: Text.AlignBottom
        }

        Column {
            id: sidebar

            opacity: 0
            anchors {
                top: parent.top
                left: parent.right
            }

            Rectangle {
                width: 48
                height: 48
                gradient: Gradient {
                    GradientStop {
                        position: 0.00;
                        color: "#b7b7b7";
                    }
                    GradientStop {
                        position: 1.00;
                        color: "#ffffff";
                    }
                }
                Image {
                    source: "../images/icon_pencil.png"
                    anchors.fill: parent
                    anchors.margins: 10
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: privateProps.startEdit()
                }
            }

            Rectangle {
                width: 48
                height: 48
                gradient: Gradient {
                    GradientStop {
                        position: 0.00;
                        color: "#b7b7b7";
                    }
                    GradientStop {
                        position: 1.00;
                        color: "#ffffff";
                    }
                }
                Image {
                    source: "../images/icon_move.png"
                    anchors.fill: parent
                    anchors.margins: 10
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: console.log("move element to be implemented")
                }
            }
        }
    }

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onPressAndHold: if (menuItem.editable) { menuItem.state = "toolbar" }
        onClicked: menuItem.clicked(menuItem)
        onPressed: menuItem.pressed(menuItem)
        onReleased: menuItem.released(menuItem)
    }

    function focusLost() {
        if (menuItem.state === "toolbar")
            menuItem.state = ""
    }

    states: [
        State {
            name: "selected"
            when: isSelected && !mousearea.pressed
            PropertyChanges { target: labelLoader; textColor: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_selected.svg" }
        },
        State {
            name: "pressed"
            when: mousearea.pressed
            PropertyChanges { target: labelLoader; textColor: "#ffffff" }
            PropertyChanges { target: textDescription; color: "#ffffff" }
            PropertyChanges { target: arrowRight; source: "../images/common/menu_column_item_arrow_white.svg" }
            PropertyChanges { target: background; source: "../images/common/menu_column_item_bg_pressed.svg" }
        },
        State {
            name: "toolbar"
            PropertyChanges { target: sidebar; opacity: 1 }
        }
    ]
}

