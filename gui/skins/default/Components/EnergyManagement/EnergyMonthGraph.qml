import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0

import "../../js/datetime.js" as DateTime

Item {
    property bool showCurrency
    property date graphDate
    property variant energyData

    signal dayClicked(int year, int month, int day)

    QtObject {
        id: privateProps
        property variant modelGraph: energyData.getGraph(EnergyData.CumulativeMonthGraph, graphDate,
                                                         showCurrency ? EnergyData.Currency : EnergyData.Consumption)
        property real maxValue: modelGraph.maxValue * 1.1
        property int columnSpacing: 6


        function showPopup(day) {
            var date = modelGraph.date
            date.setDate(day)
            loader.setComponent(dayPopupComponent, {'referredDate': date})
            darkRect.opacity = 0.3
        }

        function dateSelected(date) {
            hidePopup()
            dayClicked(date.getFullYear(), date.getMonth(), date.getDate())
        }

        function hidePopup() {
            loader.setComponent(undefined)
            darkRect.opacity = 0.0
        }


        onModelGraphChanged: hidePopup()
    }

    Rectangle {
        id: darkRect
        z: 2
        anchors.fill: graph
        opacity: 0.0
        color: "black"

        MouseArea { // prevent mouse events
            anchors.fill: parent
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    AnimatedLoader {
        id: loader
        z: 3
        anchors.centerIn: graph
        duration: 300
    }

    Component {
        id: dayPopupComponent
        SvgImage {
            anchors.centerIn: parent
            property date referredDate
            source: "../../images/energy/bg_pop-up-date.svg"

            UbuntuLightText {
                id: text
                text: qsTr("select a date")
                font.pixelSize: 14
                anchors {
                    top: parent.top
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
            }

            Row {
                id: popupFirstRow
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: text.bottom
                    topMargin: 5
                }

                ButtonImageThreeStates {
                    id: previousButton
                    repetitionOnHold: true
                    defaultImageBg: "../../images/energy/btn_freccia.svg"
                    pressedImageBg: "../../images/energy/btn_freccia_P.svg"
                    shadowImage: "../../images/energy/ombra_btn_freccia.svg"
                    defaultImage: "../../images/common/ico_freccia_sx.svg"
                    pressedImage: "../../images/common/ico_freccia_sx_P.svg"

                    onClicked: {
                        if (referredDate.getDate() > 1)
                            referredDate = DateTime.previousDay(referredDate)
                    }
                }

                SvgImage {
                    source: "../../images/common/date_panel_inner_background.svg"
                    width: 82
                    height: 42
                    UbuntuLightText {
                        id: dateLabel
                        font.pixelSize: 14
                        text: Qt.formatDateTime(referredDate, qsTr("dd/MM/yyyy"))
                        anchors.centerIn: parent
                    }
                }

                ButtonImageThreeStates {
                    id: nextButton
                    repetitionOnHold: true
                    defaultImageBg: "../../images/energy/btn_freccia.svg"
                    pressedImageBg: "../../images/energy/btn_freccia_P.svg"
                    shadowImage: "../../images/energy/ombra_btn_freccia.svg"
                    defaultImage: "../../images/common/ico_freccia_dx.svg"
                    pressedImage: "../../images/common/ico_freccia_dx_P.svg"

                    onClicked: {
                        if (referredDate.getDate() < DateTime.daysInMonth(referredDate.getMonth(), referredDate.getFullYear()))
                            referredDate = DateTime.nextDay(referredDate)
                    }
                }
            }

            ButtonThreeStates {
                anchors {
                    top: popupFirstRow.bottom
                    topMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }

                defaultImage: "../../images/common/btn_84x35.svg"
                pressedImage: "../../images/common/btn_84x35_P.svg"
                shadowImage: "../../images/common/btn_shadow_84x35.svg"
                text: qsTr("OK")
                onClicked: {
                    privateProps.dateSelected(referredDate)
                }
            }
        }
    }

    SvgImage {
        id: columnPrototype
        visible: false
        source: "../../images/energy/colonna_month.svg"
    }

    UbuntuLightText {
        id: valuesLabel
        anchors {
            top: parent.top
            topMargin: 20
            left: valuesAxis.left
        }
        text: showCurrency ? energyData.rate.currencySymbol : energyData.cumulativeUnit
        color: "white"
        font.pixelSize: 12
    }

    Item {
        id: valuesAxis
        property int numValues: 6
        anchors.top: graph.top
        anchors.bottom: graph.bottom
        anchors.left: parent.left
        width: 35

        function calculateValue(index) {
            if (index === numValues)
                return 0
            if (index === 0)
                return privateProps.maxValue

            // Because the last value is always 0, we have to use numValues - 1.
            return privateProps.maxValue / (numValues - 1) * (numValues -1 - index)
        }

        Repeater {
            UbuntuLightText {
               text: valuesAxis.calculateValue(index).toFixed(energyData.decimals)
               color: "white"
               font.pixelSize: 12
               anchors.left: parent.left
               // We remove the paintedHeight from the calculation because we want to draw
               // the last value on top of the graph colunm.
               y: index * ((columnPrototype.height - paintedHeight) / (valuesAxis.numValues - 1))
            }
            model: valuesAxis.numValues
        }
    }

    BeepingMouseArea {
        anchors.fill: graph
        onClicked: {
            // find the column that match best
            var prevWidth = 0
            var nextWidth = columnPrototype.width
            for (var i = 0; i < privateProps.modelGraph.graph.length; i += 1) {
                if (mouse.x >= prevWidth & mouse.x <= nextWidth) {
                    privateProps.showPopup(i + 1)
                    return
                }

                prevWidth = nextWidth
                nextWidth += columnPrototype.width + privateProps.columnSpacing
            }
        }
    }

    Row {
        id: graph
        anchors {
            top: valuesLabel.bottom
            topMargin: 15
            left: valuesAxis.right
        }
        spacing: privateProps.columnSpacing
        Repeater {
            Item {
                width: columnPrototype.width
                height: columnPrototype.height
                opacity: {
                    if (privateProps.modelGraph.isValid) {
                        return index < privateProps.modelGraph.graph.length ? 1: 0
                    }
                    return 1
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200; }
                }

                SvgImage {
                    source: "../../images/energy/ombra_colonna_month.svg"
                    anchors.top: parent.bottom
                }
            }
            // We draw the graph area with a fixed number of bars to optimize
            // the drawing operation, and we hide the exceeding bars (eg. the
            // 31st on 30-days months).
            // This way, when the underlying model changes the bars are not
            // redrawn anymore but simply hidden or shown.
            model: 31
        }
    }


    Row {
        id: greenBars
        anchors {
            top: graph.top
            bottom: graph.bottom
            left: graph.left
        }
        z: 1
        spacing: privateProps.columnSpacing

        Repeater {
            Item {
                height: columnPrototype.height
                width: columnPrototype.width
                SvgImage {
                    source: "../../images/energy/colonna_month_verde.svg"
                    anchors.bottom: parent.bottom
                    height: {
                        if (!privateProps.modelGraph.isValid)
                            return 0
                        else {
                            return model.modelData.value / privateProps.maxValue * columnPrototype.height
                        }
                    }
                }
            }

            model: privateProps.modelGraph.graph
        }
    }

    UbuntuLightText {
        // We use a "prototype" for the text box to have a fixed height so when
        // we change the model the periodLabel does not move anymore.
        id: graphLabelPrototype
        visible: false
        text: " "
        font.pixelSize: 12
    }

    Item {
        id: periodAxis
        height: graphLabelPrototype.height

        anchors {
            left: graph.left
            right: graph.right
            top: graph.bottom
            topMargin: 5
        }

        Repeater {
            model: privateProps.modelGraph.graph
            UbuntuLightText {
                visible: (index + 1) % 5 === 0 || index === 0
                text: model.modelData.label
                width: columnPrototype.width
                color: "white"
                font.pixelSize: graphLabelPrototype.font.pixelSize
                horizontalAlignment: Text.AlignHCenter
                x: index * (columnPrototype.width + privateProps.columnSpacing)
            }
        }
    }

    UbuntuLightText {
        id: periodLabel
        anchors {
            top: periodAxis.bottom
            topMargin: 10
            left: periodAxis.left
        }
        text: qsTr("day")
        color: "white"
        font.pixelSize: 12
    }

}



