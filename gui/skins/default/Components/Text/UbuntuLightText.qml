import QtQuick 1.1
import "../../js/MainContainer.js" as Container

Text {
    textFormat: Text.PlainText
    font.family: {
        if (Container.mainContainer.ubuntuLight)
            return Container.mainContainer.ubuntuLight.name
        else
            return ""
    }
    elide: Text.ElideRight
}
