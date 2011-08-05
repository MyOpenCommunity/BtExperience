// This declaration makes the javascript code share the execution context between
// different qml files.

.pragma library

var stack = []

var container = null

// Create a QML object from a given filename and push it on the stack
function openPage(filename) {
	var page_component = Qt.createComponent(filename)
	var page = page_component.createObject(container)
	pushPage(page)
	return page
}

function pushPage(page) {
	for (var i = 0; i < stack.length; i++) // we can do better
		stack[i].visible = false

	stack.push(page)
}

function backToHome() {
	for (var i = 1; i < stack.length; i++) {
		stack[i].visible = false
		stack[i].destroy() // destroy or not destroy?
	}

	stack.length = 1

	stack[0].visible = true
	return stack[0]
}

