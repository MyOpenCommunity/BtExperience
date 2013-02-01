import QtQuick 1.1
import "../../js/MainContainer.js" as Container

Text {
    textFormat: Text.PlainText
    font.family: {
        if (Container.mainContainer.ubuntuMedium)
            return Container.mainContainer.ubuntuMedium.name
        else
            return ""
    }
}
