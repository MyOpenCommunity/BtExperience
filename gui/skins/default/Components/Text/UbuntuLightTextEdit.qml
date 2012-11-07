import QtQuick 1.1
import "../../js/MainContainer.js" as Container

BaseTextEdit {
    font.family: {
        if (Container.mainContainer.ubuntuLight)
            return Container.mainContainer.ubuntuLight.name
        else
            return ""
    }
}
