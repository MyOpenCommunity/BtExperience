/**
  * An hiding bar showing multimedia section for saving urls in browser
  */

import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Popup 1.0
import Components.Text 1.0


Item {
    id: control

    property variant page

    signal quicklinkTypeClicked()

    width: 220
    height: 220

    Connections {
        target: global
        onAboutToHide: {
            control.state = "hidden"
            privateProps.currentIndex = -1
        }
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1
    }

    ListModel { id: choices }

    Component.onCompleted: {
        choices.append({ type: qsTr("web page"), mediaType: MediaLink.Web })
        choices.append({ type: qsTr("web camera"), mediaType: MediaLink.Webcam })
        choices.append({ type: qsTr("rss"), mediaType: MediaLink.Rss })
        choices.append({ type: qsTr("weather"), mediaType: MediaLink.RssMeteo })
        choices.append({ type: qsTr("web radio"), mediaType: MediaLink.WebRadio })

        privateProps.currentIndex = -1
    }

    Loader {
        id: loaderItem

        anchors.fill: parent
    }

    Component {
        id: theBar

        SvgImage {
            id: bg

            source: "../../images/common/bg_panel_212x100.svg"
            anchors.fill: parent

            Column {
                spacing: 10
                anchors {
                    top: bg.top
                    topMargin: 30
                    left: bg.left
                    leftMargin: 20
                }
                Repeater {
                    id: repeater
                    model: choices.count
                    delegate: ControlRadioHorizontal {
                        width: bg.width * 0.8
                        text: choices.get(index).type
                        onClicked: {
                            if (privateProps.currentIndex === index)
                                return
                            privateProps.currentIndex = index
                            page.installPopup(popupEditLink)
                        }
                        status:  privateProps.currentIndex === index
                    }
                }
            }
        }
    }

    Component {
        id: popupEditLink
        FavoriteEditPopup {
            title: qsTr("Edit quicklink properties")
            topInputLabel: qsTr("Title:")
            topInputText: ""
            bottomInputLabel: qsTr("Address:")
            bottomInputText: global.url

            function okClicked() {
                feedbackTimer.checks = 0
                if (privateProps.currentIndex === -1)
                    feedbackTimer.checks = 1
                if (topInputText === "")
                    feedbackTimer.checks = 2
                if (topInputText.indexOf("§") >= 0)
                    feedbackTimer.checks = 3
                if (feedbackTimer.checks === 0) {
                    global.createQuicklink(choices.get(privateProps.currentIndex).mediaType, topInputText, bottomInputText)
                    quicklinkTypeClicked()
                }
                else {
                    feedbackTimer.start()
                }
            }
        }
    }

    Component {
        id: noChoiceFeedback
        FeedbackPopup {
            text: qsTr("No type selection")
            isOk: false
        }
    }

    Component {
        id: noNameFeedback
        FeedbackPopup {
            text: qsTr("Name cannot be empty")
            isOk: false
        }
    }

    Component {
        id: noSepFeedback
        FeedbackPopup {
            text: qsTr("Name cannot contain § char")
            isOk: false
        }
    }

    Timer {
        id: feedbackTimer

        property int checks: 0

        interval: 200
        repeat: false
        onTriggered: {
            if (checks === 1)
                page.installPopup(noChoiceFeedback)
            else if (checks === 2)
                page.installPopup(noNameFeedback)
            else if (checks === 3)
                page.installPopup(noSepFeedback)
        }
    }

    state: "hidden"

    states: [
        State {
            name: "hidden"
            extend: ""
        },
        State {
            name: "visible"
            PropertyChanges {
                target: loaderItem
                sourceComponent: theBar
            }
        }
    ]
}
