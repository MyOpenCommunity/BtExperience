import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    ObjectModel {
        // this must stay here otherwise theModel cannot be constructed properly
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMessages}]
    }

    MediaModel {
        id: theModel
        source: objectModel.getObject(0).messages
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    SvgImage {
        id: imageBg
        source: "../../images/common/bg_messaggi_ricevuti.svg"
    }

    UbuntuLightText {
        id: caption

        font.pixelSize: 14

        text: paginator.model.count === 0 ? "" : paginator.model.count + (paginator.model.count === 1 ? qsTr(" message") : qsTr(" messages"))
        verticalAlignment: Text.AlignVCenter
        color: "gray"
        anchors {
            top: imageBg.top
            topMargin: imageBg.height / 100 * 2.65
            left: imageBg.left
            leftMargin: imageBg.width / 100 * 2.83
        }
    }

    PaginatorOnBackground {
        id: paginator

        elementsOnPage: 9
        buttonVisible: model.count !== 0
        spacing: 5

        anchors {
            top: imageBg.top
            topMargin: imageBg.height / 100 * 10.62
            bottom: imageBg.bottom
            bottomMargin: imageBg.height / 100 * 2.65
            left: imageBg.left
            leftMargin: imageBg.width / 100 * 2.83
            right: imageBg.right
            rightMargin: imageBg.width / 100 * 2.83
        }

        delegate: ColumnMessagesDelegate {
            itemObject: theModel.getObject(index)
        }

        model: theModel
    }
}
