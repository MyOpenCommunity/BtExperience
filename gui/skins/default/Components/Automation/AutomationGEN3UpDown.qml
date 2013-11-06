/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    ControlAutomation3Group {
        leftIcon: "../../images/common/ico_alza.svg"
        leftPressedIcon: "../../images/common/ico_alza_P.svg"
        middleIcon: "../../images/common/ico_alza.svg"
        middlePressedIcon: "../../images/common/ico_alza_P.svg"
        rightIcon: "../../images/common/ico_abbassa.svg"
        rightPressedIcon: "../../images/common/ico_abbassa_P.svg"
        onPressed: dataModel.status = newStatus
    }
}
