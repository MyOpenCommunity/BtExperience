import QtQuick 1.0
import "Stack.js" as Stack


Page {
	id: root

	Component.onCompleted: {
		Stack.root_window = root
		Stack.openPage("HomePage.qml")
	}
}
