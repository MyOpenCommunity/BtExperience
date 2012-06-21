import QtQuick 1.1
import BtObjects 1.0
import "js/array.js" as Script


QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['FIXED_TIMING'] = []
        /*
          Due to bug https://bugreports.qt-project.org/browse/QTBUG-21672
          we have to trick the -1 value. See also comment in lightobjects.h
          to FixedTimingType enum
          */
        container['FIXED_TIMING'][/*Light.FixedTimingDisabled*/ -1] = qsTr("Disabled")
        container['FIXED_TIMING'][Light.FixedTimingMinutes1] = qsTr("1 Minute")
        container['FIXED_TIMING'][Light.FixedTimingMinutes2] = qsTr("2 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingMinutes3] = qsTr("3 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingMinutes4] = qsTr("4 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingMinutes5] = qsTr("5 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingMinutes15] = qsTr("15 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingSeconds30] = qsTr("30 Seconds")
        container['FIXED_TIMING'][Light.FixedTimingSeconds0_5] = qsTr("0.5 Seconds")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
