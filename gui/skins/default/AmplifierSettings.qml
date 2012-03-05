import QtQuick 1.1

MenuElement {
    id: amplifierSettings
    width: 212
    height: page1.visible ? page1.height : page2.height

    Item {
        id: page1
        height: childrenRect.height

        ControlSlider {
            id: treble
            description: qsTr("treble")
            percentage: 10
        }

        ControlSlider {
            id: bass
            description: qsTr("bass")
            percentage: 35
            anchors.top: treble.bottom
        }
    }

    Item {
        id: page2
        visible: false
        height: childrenRect.height

        ControlBalance {
            id: balance
            percentage: 10
        }

        MenuItem {
            id: equalizer
            name: qsTr("equalizer")
            anchors.top: balance.bottom
            active: amplifierSettings.animationRunning === false
            description: "off"
            hasChild: true
            onClicked: amplifierSettings.loadElement("AmplifierEqualizer.qml", qsTr("equalizer"))
        }

        MenuItem {
            id: loudness
            name: qsTr("loud")
            anchors.top: equalizer.bottom
            active: amplifierSettings.animationRunning === false
            description: "on"
            hasChild: true
            // TODO: a dirty trick to avoid creating another almost empty file.
            // This must be linked to the model anyway.
            onClicked: amplifierSettings.loadElement("Light.qml", qsTr("loud"))
        }
    }

    Image {
        id: rectangle1
        width: 212
        height: 35
        source: "images/common/bg_paginazione.png"
        anchors.top: amplifierSettings.bottom

        Row {
            anchors.fill: parent

            Image {
                // TODO: copy-pasted from ButtonPagination, make it better
                id: leftArrow
                width: 42
                height: 35
                source: "images/common/btn_NumeroPagina.png"

                Image {
                    id: image1
                    x: 10
                    y: 4
                    source: "images/common/freccia_sx.png"
                }
            }

            ButtonPagination {
                pageNumber: 1
                onClicked: amplifierSettings.state = "page" + pageNumber
            }

            ButtonPagination {
                pageNumber: 2
                onClicked: amplifierSettings.state = "page" + pageNumber
            }

            Image {
                // TODO: copy-pasted from ButtonPagination, make it better
                id: rightArrow
                width: 42
                height: 35
                source: "images/common/btn_NumeroPagina.png"

                Image {
                    id: image2
                    x: 10
                    y: 3
                    source: "images/common/freccia_dx.png"
                }
            }
        }
    }



    states: [
        State {
            name: "page1"
            PropertyChanges {
                target: page2
                visible: false
            }
            PropertyChanges {
                target: page1
                visible: true
            }
        },
        State {
            name: "page2"
            PropertyChanges {
                target: page1
                visible: false
            }
            PropertyChanges {
                target: page2
                visible: true
            }
        }
    ]
}
