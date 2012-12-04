import QtQuick 1.1
import BtExperience 1.0
import BtObjects 1.0
import "js/Stack.js" as Stack
import Components 1.0

BasePage {
    id: webBrowser

    property string urlString

    Rectangle {
        color: "black"
        opacity: 0.5
        anchors.fill: parent
    }

    BrowserProcess {
        id: browserProcess

        onTerminated: {
            global.screenState.disableState(ScreenState.ForcedNormal)
            Stack.popPage()
        }
    }

    Component.onCompleted: {
        global.screenState.enableState(ScreenState.ForcedNormal)
        browserProcess.start(urlString)
    }
}
