import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    SvgImage {
        id: bg
        source: "../../images/common/bg_comando.svg"

        ButtonThreeStates {
            text: dataModel.name
            defaultImage: "../../images/common/btn_apriporta_ok_on.svg"
            pressedImage: "../../images/common/btn_apriporta_ok_on_P.svg"
            shadowImage: "../../images/common/ombra_btn_apriporta_ok_on.svg"
            onPressed: dataModel.staircaseLightActivate()
            onReleased: dataModel.staircaseLightRelease()
            font.pixelSize: 16
            elide: Text.ElideMiddle
            anchors {
                centerIn: parent
            }
        }
    }
}
