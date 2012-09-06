import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    SvgImage {
        id: imageBg
        source: "../../images/common/bg_nuovo_messaggio.svg"
    }

    SvgImage {
        id: textBg
        source: "../../images/common/bg_testo_messaggio.svg"
        anchors {
            bottom: imageBg.bottom
            bottomMargin: imageBg.height / 100 * 7.35
            left: imageBg.left
            leftMargin: imageBg.width / 100 * 1.53
        }
    }
}
