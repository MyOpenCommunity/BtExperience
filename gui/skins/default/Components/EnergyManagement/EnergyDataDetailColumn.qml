import QtQuick 1.1



Column {
    id: element

    width: 150
    height: 350

    property int level_actual: 135
    property int level_critical: 150
    property real perc_warning: 0.8
    property string title: "title"
    property string description: "descr"
    property string footer: "footer"
    property string source: "../../images/common/svg_bolt.svg"
    property string note_header: "note header"
    property string note_footer: "note footer"
    property bool critical_bar_visible: false

    signal clicked

    EnergyDataOverviewColumn {
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * 300 / 350
        level_actual: element.level_actual
        perc_warning: element.perc_warning
        level_critical: element.level_critical
        title: element.title
        description: element.description
        footer: element.footer
        source: element.source
        critical_bar_visible: element.critical_bar_visible
        onClicked: element.clicked()
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        color: "gray"
        opacity: 1
        radius: 4
        height: parent.height * 40 / 350
        Text {
            text: element.note_header
            color: "white"
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 2
            }
            horizontalAlignment: Text.AlignHCenter
        }
        Text {
            text: element.note_footer
            color: "white"
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 2
            }
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
