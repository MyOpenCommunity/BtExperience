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
        source: "../../images/common/bg_panel_212x100.svg"

        ButtonThreeStates {
            id: associate
            text: qsTr("Associate")
            defaultImage: "../../images/common/btn_84x35.svg"
            pressedImage: "../../images/common/btn_84x35_P.svg"
            selectedImage: "../../images/common/btn_84x35_S.svg"
            shadowImage: "../../images/common/btn_shadow_84x35.svg"
            anchors.top: parent.top
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 7
            anchors.right: parent.right
            anchors.rightMargin: 7
            enabled: !privateProps.model.teleloopAssociating
            onClicked: privateProps.model.startTeleloopAssociation()
        }

        UbuntuMediumText {
            text: privateProps.model.associatedTeleloopId ? qsTr("Associated") : qsTr("Not associated")
            anchors.top: associate.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
        }
    }
}
