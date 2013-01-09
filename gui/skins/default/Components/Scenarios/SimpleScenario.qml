import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import Components.Popup 1.0

MenuColumn {
    id: column
    MenuItem {
        name: qsTr("activate")
        onClicked: {
            column.dataModel.activate()
            pageObject.installPopup(feedback)
        }
    }

    Connections {
        target: pageObject.popupLoader.item
        onClosePopup: column.closeColumn()
    }

    Component {
        id: feedback
        FeedbackPopup {
            text: column.dataModel.name + qsTr(": command sent")
            isOk: true
        }
    }
}
