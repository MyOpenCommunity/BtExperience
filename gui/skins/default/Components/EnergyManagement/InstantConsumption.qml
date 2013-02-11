import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: control

    property variant load
    property bool showCurrency

    source: "../../images/common/bg_on-off.svg"

    UbuntuLightText {
        text: qsTr("Instant consumption")
        color: "gray"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            top: parent.top
            topMargin: parent.height / 100 * 15
            left: parent.left
            leftMargin: parent.width / 100 * 5
        }
    }

    UbuntuLightText {
        text: privateProps.getConsumptionText(showCurrency, load.consumption, load.currentUnit, load.expense, load.rate)
        color: "white"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height / 100 * 15
            left: parent.left
            leftMargin: parent.width / 100 * 5
        }
    }

    QtObject {
        id: privateProps

        function getConsumptionText(showCurrency, consumption, currentUnit, expense, rate) {
            if (showCurrency) {
                if (expense === 0)
                    return "--"
                else
                    return expense + " " + rate.currencySymbol
            }
            else {
                if (consumption === 0)
                    return "--"
                else
                    return consumption + " " + currentUnit
            }
        }
    }
}
