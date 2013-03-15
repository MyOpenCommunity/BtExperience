import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: bg

    property url defaultImage: ""
    property url pressedImage: ""
    property url selectedImage: ""
    property url shadowImage: ""

    property alias text: label.text
    property alias font: label.font
    property alias textAnchors: label.anchors
    property alias elide: label.elide
    property alias horizontalAlignment: label.horizontalAlignment
    property alias pressAndHoldEnabled: area.pressAndHoldEnabled
    property alias maximumLineCount: label.maximumLineCount
    property alias wrapMode: label.wrapMode

    property bool enabled: true
    property int status: 0 // 0 - up, 1 - down

    // normal clicked event; if you want to react on press events, use the touched()
    // signal
    signal clicked(variant mouse)
    signal held(variant mouse)
    // normal press and release events on button
    signal pressed(variant mouse)
    signal released(variant mouse)
    // allows the button to react on press events but also showing the 'pressed'
    // image
    signal touched

    source: defaultImage

    BeepingMouseArea {
        id: area

        anchors.fill: parent

        onClicked: bg.clicked(mouse)
        onHeld: bg.held(mouse)
        onPressed: {
            touchTimer.restart()
            bg.pressed(mouse)
        }
        onReleased: bg.released(mouse)

        Timer {
            id: touchTimer
            interval: 50
            onTriggered: bg.touched()
        }
    }

    Rectangle {
        z: 1
        anchors.fill: parent
        color: "silver"
        opacity: 0.6
        visible: bg.enabled === false
        MouseArea {
            anchors.fill: parent
        }
    }

    UbuntuLightText {
        id: label

        color: "black"
        anchors.centerIn: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        width: parent.width / 100 * 90
        elide: Text.ElideRight
    }

    SvgImage {
        id: shadow
        anchors {
            left: bg.left
            top: bg.bottom
            right: bg.right
        }
        source: shadowImage
    }

    // when clauses exhibit a weird behavior: when evaluating to false they
    // come back to the initial state (instead of default one as stated in the
    // documentation, see http://doc-snapshot.qt-project.org/4.8/qdeclarativestates.html#the-property)
    // to avoid this, I defined a normal state that corresponds to default one
    // it is defined as last, so we can use another property of when clauses
    // i.e. the evaluation order of when clauses (see http://doc.qt.nokia.com/4.7-snapshot/qml-state.html#when-prop)
    // in practice, the normal state is defined as last with a when property
    // equal to true, in this way, if the preceding when clauses are false
    // the state defaults to normal (it is a sort of catch-all-state)
    states: [
        State {
            name: "pressed"
            when: (area.pressed) && (status === 0)
            PropertyChanges { target: bg; source: pressedImage }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: label; color: "white" }
        },
        State {
            name: "selected"
            when: (status === 1)
            PropertyChanges { target: bg; source: selectedImage }
            PropertyChanges { target: shadow; visible: false }
            PropertyChanges { target: label; color: "white" }
        },
        State {
            name: "normal"
            when: { return true }
            PropertyChanges { target: bg; source: defaultImage }
            PropertyChanges { target: shadow; visible: true }
            PropertyChanges { target: label; color: "black" }
        }
    ]
}
