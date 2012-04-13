import QtQuick 1.1
import BtExperience 1.0


Image {
    id: image
    width: image_reader.width
    height: image_reader.height
    sourceSize.width: image_reader.width
    sourceSize.height: image_reader.height
    asynchronous: false

    ImageReader {
        id: image_reader
        fileName: image.source
    }
}

