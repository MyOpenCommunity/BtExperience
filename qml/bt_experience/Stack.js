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

	if (stack.length > 0) {
		page.state = 'offscreen_right'
		page.state = ''
	}
	stack.push(page)
}

function pushPageDone() {
	for (var i = 1; i < stack.length; i++)
		stack[i].z = 0
}

function backToHome() {
	stack[0].state = 'offscreen_left'
	stack[0].state = ''

	return stack[0]
}

function backToHomeDone() {
	for (var i = 1; i < stack.length; i++) {
		stack[i].visible = false
		stack[i].destroy()
	}

	stack.length = 1
	stack[0].z = 0
}


