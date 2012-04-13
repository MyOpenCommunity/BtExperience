import QtQuick 1.1
import BtExperience 1.0
import "../js/datetime.js" as DateTime


Item {
    id: toolbar

    property string imagesPath: "../images/"
    property string fontFamily
    property int fontSize: 15
    signal homeClicked
    signal exitClicked

    width: 1024
    height: 50

    Column {
        id: bg
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        SvgImage {
            source: imagesPath + "toolbar/toolbar_bg_top.svg"
            width: parent.width

                Row {
                    id: toolbarLeft
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left

                    Item {
                        // TODO: the width and height should be calculated from the size of images.
                        // However, the Row/Column calculate their size depending on the size of their
                        // children. This is a kind of loop, so for the moment we hardcode the size of
                        // the children.
                        width: 58
                        height: 50

                        SvgImage {
                            source: imagesPath + "toolbar/icon_home.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                anchors.fill: parent
                                onClicked: toolbar.homeClicked()
                            }
                        }
                    }

                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_separator.svg"
                    }

                    Item {
                        width: 56
                        height: 50

                        Text {
                            id: temperature
                            text: "19°C"
                            font.pixelSize: toolbar.fontSize
                            font.family: toolbar.fontFamily
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_separator.svg"
                    }

                    Item {
                        width: 113
                        height: 50

                        Text {
                            id: date
                            font.pixelSize: toolbar.fontSize
                            font.family: toolbar.fontFamily
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            function setDate(d) {
                                text = DateTime.format(d)["date"]
                            }
                        }
                    }


                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_separator.svg"
                    }

                    Item {
                        width: 65
                        height: 50

                        Text {
                            id: time
                            text: DateTime.format()["time"]
                            font.pixelSize: toolbar.fontSize
                            font.family: toolbar.fontFamily
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            function setTime(d) {
                                text = DateTime.format(d)["time"]
                            }
                        }
                    }

                    Timer {
                        id: changeDateTime
                        interval: 500
                        repeat: true
                        running: true
                        triggeredOnStart: true
                        onTriggered: { var d = new Date(); date.setDate(d); time.setTime(d) }
                    }

                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_separator.svg"
                    }
                }


                Item {
                    anchors.left: toolbarLeft.right
                    anchors.right: toolbarRight.left
                    height: 50


                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_logo_white.svg"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    id: toolbarRight
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_separator.svg"
                    }

                    Item {
                        width: 60
                        height: 50
                        SvgImage {
                            source: imagesPath + "toolbar/icon_alert.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter

                        }
                    }

                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_separator.svg"
                    }

                    Item {
                        width: 60
                        height: 50
                        SvgImage {
                            source: imagesPath + "toolbar/icon_antintrusion.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter

                        }
                    }

                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_separator.svg"
                    }

                    Item {
                        width: 60
                        height: 50
                        SvgImage {
                            source: imagesPath + "toolbar/icon_clock.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter

                        }
                    }

                    SvgImage {
                        source: imagesPath + "toolbar/toolbar_separator.svg"
                    }

                    Item {
                        width: 68
                        height: 50
                        SvgImage {
                            source: imagesPath + "toolbar/icon_quit.svg"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter

                        }
                    }
                }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_bg_bottom.svg"
            width: parent.width
        }
    }




}
