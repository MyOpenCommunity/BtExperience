import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    ControlAutomation3Group {
        leftIcon: "../../images/common/ico_apri.svg"
        leftPressedIcon: "../../images/common/ico_apri_P.svg"
        rightIcon: "../../images/common/ico_chiudi.svg"
        rightPressedIcon: "../../images/common/ico_chiudi_P.svg"
        onPressed: column.dataModel.setStatus(newStatus)
    }
}
