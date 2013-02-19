import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    Column {

        Item {
            width: bg.width
            height: bg.height

            SvgImage {
                id: bg
                source: "../../images/common/bg_comando.svg"
            }

            ButtonThreeStates {
                anchors.centerIn: parent
                defaultImage: "../../images/common/btn_apriporta_ok_on.svg"
                pressedImage: "../../images/common/btn_apriporta_ok_on_P.svg"
                selectedImage: "../../images/common/btn_apriporta_ok_on.svg"
                shadowImage: "../../images/common/ombra_btn_apriporta_ok_on.svg"
                text: "start"
                onPressed: column.dataModel.start()
            }
        }

        ControlSwitch {
            text: column.dataModel.enabled ? qsTr("enabled") : qsTr("disabled")
            onClicked: column.dataModel.enabled = !column.dataModel.enabled
            status: !column.dataModel.enabled
        }
    }
}
