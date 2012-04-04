import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    width: 212
    height: paginator.height + backButton.height

    PaginatorList {
        id: paginator

        listHeight: 50 * paginator.elementsOnPage
        delegate: MenuItemDelegate {
            itemObject: files.getObject(index)
            name: itemObject.name
            hasChild: itemObject.fileType === FileObject.Directory ? true : false
            // TODO: quick hack to distinguish directories from files
            status: hasChild ? 0 : -1
            onDelegateClicked: {
                console.log("SongBrowser, clicked on: " + itemObject.name)
                if (hasChild) {
                    files.enterDirectory(itemObject.name)
                }
            }
        }

        model: files
    }

    MenuItem {
        id: backButton
        anchors.bottom: parent.bottom
        name: "back"
        description: "Go directory up"
        onClicked: files.exitDirectory()
    }

    DirectoryListModel {
        id: files
        rootPath: ['usr', 'local', 'lottaviano', 'music']
        filter: FileObject.Audio | FileObject.Directory
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }
}
