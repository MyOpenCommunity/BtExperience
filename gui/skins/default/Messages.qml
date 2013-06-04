import QtQuick 1.1
import Components.Messages 1.0
import BtObjects 1.0

/**
  \ingroup Core

  \brief The Messages system page.
  */
SystemPage {
    source: "images/background/messages.jpg"
    text: systemNames.get(Container.IdMessages)
    rootColumn: Component { MessagesItems { } }
}
