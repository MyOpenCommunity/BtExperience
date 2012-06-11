import QtQuick 1.1
import Components 1.0
import BtObjects 1.0


Item {
    id: element

    property string title: "40 kWh"
    property string description: "electricity"
    property int valueType: EnergyData.CumulativeMonthGraph
    property string source: "../../images/common/svg_bolt.svg"

    // properties to be passed to the ControlColumnBar component
    property real perc_warning: 0.8
    property int level_critical: 100
    property int level_actual: 40
    property bool critical_bar_visible: true

    signal clicked

    Rectangle {
        // the graphical button on top of the bar
        id: button
        height: 0.25 * parent.height
        color: "white"
        anchors {
            top: element.top
            left: element.left
            right: element.right
        }
        SvgImage {
            source: element.source
            width: 0.5 * parent.height
            height: 0.5 * parent.height
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
        }
        UbuntuLightText {
            text: element.description
            color: "black"
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 5
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: element.clicked()
        }
    }

    Item {
        // the title on top of the bar (below the graphical button)
        id: title
        height: parent.height / 12
        anchors {
            top: button.bottom
            left: button.left
            right: button.right
        }
        Rectangle {
            // a rectangle used to make text more readable
            color: "gray"
            opacity: 1
            radius: 4
            height: parent.height * 2 / 3
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                right: parent.right
            }
            UbuntuLightText {
                text: element.title
                color: "white"
                anchors {
                    fill: parent
                    centerIn: parent
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    ControlColumnBar {
        id: graph
        height: parent.height * 7 / 12
        anchors {
            top: title.bottom
            left: title.left
            right: title.right
        }
        perc_warning: element.perc_warning
        level_critical: element.level_critical
        level_actual: element.level_actual
        critical_bar_visible: element.critical_bar_visible
    }


    function daysInMonth(month,year)
    {
       return new Date(year, month, 0).getDate();
    }

    function formatFooter(date) {
        var footer = ""
        switch (valueType)
        {
        case EnergyData.CumulativeDayValue:
            footer += qsTr("hour ")
            footer += Qt.formatDateTime(date, "h/24")
            break;
        case EnergyData.CumulativeMonthValue:
            footer += qsTr("day ")
            footer += Qt.formatDateTime(date, "d/") + daysInMonth(date.getFullYear(), date.getMonth())
            break;
        case EnergyData.CumulativeYearValue:
            footer += qsTr("month ")
            footer += Qt.formatDateTime(date, "M/12")
            break;
        }
        return footer
    }

    Item {
        // a text below the bar
        id: footer
        height: parent.height / 12
        anchors {
            top: graph.bottom
            left: graph.left
            right: graph.right
        }
        Rectangle {
            color: "gray"
            opacity: 1
            radius: 4
            height: parent.height * 2 / 3
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                right: parent.right
            }
            UbuntuLightText {
                text: formatFooter(new Date())
                color: "white"
                anchors {
                    fill: parent
                    centerIn: parent
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
