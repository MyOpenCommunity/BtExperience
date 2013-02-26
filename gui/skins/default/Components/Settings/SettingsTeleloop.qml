import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column
    ObjectModel {
        id: vctModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    QtObject {
        id: privateProps
        property variant model: vctModel.getObject(0)
    }

    SvgImage {
        id: bg
        source: "../../images/common/bg_panel_212x100.svg"

        ButtonThreeStates {
            id: associate
            text: qsTr("Associate")
            defaultImage: "../../images/common/btn_84x35.svg"
            pressedImage: "../../images/common/btn_84x35_P.svg"
            selectedImage: "../../images/common/btn_84x35_S.svg"
            shadowImage: "../../images/common/btn_shadow_84x35.svg"
            anchors {
                top: parent.top
                topMargin: Math.round(bg.height / 100 * 5)
                left: parent.left
                leftMargin: Math.round(bg.width / 100 * 3)
                right: parent.right
                rightMargin: Math.round(bg.width / 100 * 3)
            }
            enabled: !privateProps.model.teleloopAssociating
            onPressed: privateProps.model.startTeleloopAssociation()
        }

        UbuntuMediumText {
            text: privateProps.model.associatedTeleloopId ? qsTr("Associated") : qsTr("Not associated")
            anchors {
                top: associate.bottom
                topMargin: Math.round(bg.height / 100 * 20)
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: 15
        }
    }
}
