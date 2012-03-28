import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: 200
    signal timezoneChanged(int gmtOffset)


    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 400

        ControlChoices {
            id: tmz
            description: qsTr("time zone")
            choice: pageObject.names.get('TIMEZONE', 0)
            property int currentIndex: 0
            onPlusClicked: {
                if (currentIndex < 2) {
                    choice = pageObject.names.get('TIMEZONE', ++currentIndex)
                }
            }
            onMinusClicked: {
                if (currentIndex > -2) {
                    choice = pageObject.names.get('TIMEZONE', --currentIndex)
                }
            }
        }
        ButtonOkCancel {
            onOkClicked: {
                element.timezoneChanged(tmz.currentIndex)
            }
        }
    }
}
