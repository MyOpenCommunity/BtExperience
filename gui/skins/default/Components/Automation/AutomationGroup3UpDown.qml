import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    ControlAutomation3Group {
        leftIcon: "../../images/common/ico_alza.svg"
        leftPressedIcon: "../../images/common/ico_alza_P.svg"
        rightIcon: "../../images/common/ico_abbassa.svg"
        rightPressedIcon: "../../images/common/ico_abbassa_P.svg"
        onPressed: column.dataModel.setStatus(newStatus)
    }
}
