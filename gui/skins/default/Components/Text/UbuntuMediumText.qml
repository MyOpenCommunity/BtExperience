import QtQuick 1.1
import "../../js/MainContainer.js" as Container

Text {
    font.family: {
        if (Container.mainContainer.ubuntuMedium)
            return Container.mainContainer.ubuntuMedium.name
        else
            return ""
    }
}
