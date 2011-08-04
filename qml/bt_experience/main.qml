import QtQuick 1.0
import "Stack.js" as Stack


Page {
	id: container

	Component.onCompleted: {
		Stack.container = container
		Stack.openPage("HomePage.qml")
	}
}
