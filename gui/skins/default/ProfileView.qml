import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "ProfileView.js" as Script

// Implementation of custom profile view
Item {
    id: profileView
    property variant model: undefined
    property variant container: undefined

    function updateView() {
        clearObjects()
        createObjects()
    }

    Connections {
        target: model
        onModelReset: {
            // TODO: maybe we can optimize performance by setting opacity to 0
            // for items that we don't want to show, thus avoiding a whole
            // createObject()/destroy() cycle each time
            // Anyway, this needs a more complex management and performance gains
            // must be measurable.
            updateView()
        }
    }

    function clearObjects() {
        var len = Script.obj_array.length
        for (var i = 0; i < len; ++i)
            Script.obj_array.pop().destroy()
    }

    function createObjects() {
        for (var i = 0; i < model.count; ++i) {
            var obj = model.getObject(i);
            var y = obj.position.y
            var x = obj.position.x
            var text = obj.name
            var address = obj.address
            var component_name;

            if (obj.type == MediaLink.Web) {
                component_name = 'FavoriteItem.qml'
            } else if (obj.type == MediaLink.Rss) {
                component_name = 'RssItem.qml'
            } else if (obj.type == MediaLink.Camera) {
                component_name = 'CameraLink.qml'
            }

            var component = Qt.createComponent(component_name)
            var instance = component.createObject(profileView, {'x': x, 'y': y, 'text': text, 'address': address})

            instance.requestEdit.connect(function (instance) {
                container.showEditBox(instance)
            })
            instance.selected.connect(function (instance) {
                bringOver(instance)
            })
            Script.obj_array.push(instance)
        }
    }

    Component.onCompleted: {
        createObjects()
    }

    function bringOver(favorite) {
        favorite.z = bgPannable.z + 1
        bgPannable.visible = true
        bgPannable.actualFavorite = favorite
    }

    Rectangle {
        id: bgPannable

        property variant actualFavorite: undefined

        visible: false
        color: "black"
        opacity: 0.5
        radius: 20
        anchors.fill: parent
        z: 1
        MouseArea {
            anchors.fill: parent
            onClicked: {
                bgPannable.visible = false
                bgPannable.actualFavorite.z = 0
                bgPannable.actualFavorite.state = ""
                // TODO gestire il focus?
                bgPannable.actualFavorite = undefined
            }
        }
    }
}
