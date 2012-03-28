import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: 250
    signal timeChanged(int auto, int format)

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 400

        ControlChoices {
            description: qsTr("automatic update")
            choice: pageObject.names.get('AUTO_UPDATE', 0)
            property int currentIndex: 0
            onPlusClicked: {
                if (currentIndex < 1) {
                    choice = pageObject.names.get('AUTO_UPDATE', ++currentIndex)
                }
            }
            onMinusClicked: {
                if (currentIndex >= 0) {
                    choice = pageObject.names.get('AUTO_UPDATE', --currentIndex)
                }
            }
        }

        ControlChoices {
            description: qsTr("format")
            choice: pageObject.names.get('FORMAT', 0)
            property int currentIndex: 0
            onPlusClicked: {
                if (currentIndex < 1) {
                    choice = pageObject.names.get('FORMAT', ++currentIndex)
                }
            }
            onMinusClicked: {
                if (currentIndex >= 0) {
                    choice = pageObject.names.get('FORMAT', --currentIndex)
                }
            }
        }
        ButtonOkCancel {
            // TODO manage OK and Cancel buttons
        }
    }
}
