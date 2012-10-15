import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    signal timezoneChanged(int gmtOffset)

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 400

        ControlChoices {
            id: tmz
            description: qsTr("time zone")
            choice: pageObject.names.get('TIMEZONE', currentIndex)
            property int currentIndex: global.guiSettings.timezone
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
                column.timezoneChanged(tmz.currentIndex)
            }
        }
    }
}
