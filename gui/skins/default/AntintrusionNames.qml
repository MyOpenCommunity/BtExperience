import QtQuick 1.1
import BtObjects 1.0
import "js/array.js" as Script


/**
  \ingroup Antintrusion

  \brief Translations for the Antintrusion system.
  */
QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['ALARM_TYPE'] = []
        container['ALARM_TYPE'][AntintrusionAlarm.Antipanic] = qsTr("anti-panic")
        container['ALARM_TYPE'][AntintrusionAlarm.Intrusion] = qsTr("intrusion detection")
        container['ALARM_TYPE'][AntintrusionAlarm.Technical] = qsTr("technical")
        container['ALARM_TYPE'][AntintrusionAlarm.Tamper] = qsTr("tamper")
    }

    /**
      Retrieves the requested value from the local array.
      @param type:string context The translation context to distinguish between similar id.
      @param type:int id The id referring to the string to be translated.
      */
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
