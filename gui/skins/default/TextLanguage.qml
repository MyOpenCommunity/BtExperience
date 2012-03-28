import QtQuick 1.1
import BtObjects 1.0

Language {
    id: element
    signal textLanguageChanged(int config)
    onLanguageChanged: textLanguageChanged(config)
}
