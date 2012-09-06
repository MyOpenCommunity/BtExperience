import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    SvgImage {
        id: imageBg
        source: "../../images/common/bg_messaggio.svg"
    }

    UbuntuLightText {
        id: text

        font.pixelSize: 20

        text: column.dataModel.text
        anchors {
            top: imageBg.top
            topMargin: imageBg.height / 100 * 3.32
            left: imageBg.left
            leftMargin: imageBg.width / 100 * 2.83
            right: imageBg.right
            rightMargin: imageBg.width / 100 * 2.83
        }
    }
}
