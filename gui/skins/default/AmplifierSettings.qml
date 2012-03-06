import QtQuick 1.1

MenuElement {
    id: amplifierSettings
    width: 212
    height: pageLoader.height + paginator.height

    Component {
        id: page1

        Column {
            ControlSlider {
                id: treble
                description: qsTr("treble")
                percentage: 10
            }

            ControlSlider {
                id: bass
                description: qsTr("bass")
                percentage: 35
            }
        }
    }

    Component {
        id: page2

        Column {
            ControlBalance {
                id: balance
                percentage: 10
            }

            MenuItem {
                id: equalizer
                name: qsTr("equalizer")
                active: amplifierSettings.animationRunning === false
                description: "off"
                hasChild: true
                onClicked: amplifierSettings.loadElement("AmplifierEqualizer.qml", qsTr("equalizer"))
            }

            MenuItem {
                id: loudness
                name: qsTr("loud")
                active: amplifierSettings.animationRunning === false
                description: "on"
                hasChild: true
                // TODO: a dirty trick to avoid creating another almost empty file.
                // This must be linked to the model anyway.
                onClicked: amplifierSettings.loadElement("Light.qml", qsTr("loud"))
            }
        }
    }

    Loader {
        id: pageLoader
        sourceComponent: page1
        anchors.top: parent.top
    }

    Image {
        id: paginator
        width: 212
        height: 35
        source: "images/common/bg_paginazione.png"
        anchors.bottom: parent.bottom

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
                onClicked: amplifierSettings.state = (pageNumber === 1) ? "" : "page" + pageNumber
            }

            ButtonPagination {
                pageNumber: 2
                onClicked: amplifierSettings.state = (pageNumber === 1) ? "" : "page" + pageNumber
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
            name: "page2"
            PropertyChanges {
                target: pageLoader
                sourceComponent: page2
            }
        }
    ]
}
