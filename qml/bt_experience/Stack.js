// This declaration makes the javascript code share the execution context between
// different qml files.

.pragma library

var stack = []

var root_window = null

// Create a QML object from a given filename and push it on the stack
function openPage(filename) {
	var page_component = Qt.createComponent(filename)
	var page = page_component.createObject(root_window)
	pushPage(page)
	return page
}

function pushPage(page) {
	for(var i = stack.length - 2; i >= 0; i--)
		stack[i].visible = false

	stack.push(page)
}

