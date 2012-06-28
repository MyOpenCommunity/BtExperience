import QtQuick 1.1

QtObject {
    property variant monthConsumptionItem: undefined
    property variant goal: monthConsumptionItem !== undefined ? monthConsumptionItem.consumptionGoal : 0.0
    property variant consumption: monthConsumptionItem !== undefined ? monthConsumptionItem.value : 0.0

    function maxHeight(columnHeight) {
        return columnHeight * .95
    }

    function idealGoalHeight(columnHeight) {
        return columnHeight * .9
    }

    // the height of goal line. Can be as the "ideal" goal height or less if
    // the consumption height is greater than the maximum height.
    function goalHeight(columnHeight) {
        if (goal === undefined) // the goal line is not shown at all, using hasGoal()
            return 0.0

        var height = consumption / goal * idealGoalHeight(columnHeight)
        if (height > maxHeight(columnHeight))
            return goal / consumption * idealGoalHeight(columnHeight)
        else
            return idealGoalHeight(columnHeight)
    }

    // the height of the consumption bar. It is a value related to the goal
    // height, and it has a maximum value (in the latter case, the goal height
    // is decreased proportionally).
    function getConsumptionHeight(columnHeight) {
        if (consumption === undefined)
            return 0

        if (goal !== undefined) {
            var height = consumption / goal * idealGoalHeight(columnHeight)
            return Math.min(height, maxHeight(columnHeight))
        }
        else {
            // a very simplified representation of the consumption height,
            // proportionally to the days elapsed in the month.
            // TODO: find a better representation!
            var d = new Date()
            return d.getDate() / 30 * idealGoalHeight(columnHeight)
        }
    }

    // return true if the consumption exceed the goal (and, of course, if both are present)
    function consumptionExceedGoal() {
        if (consumption !== undefined && goal !== undefined) {
            if (consumption > goal)
                return true
        }
        return false
    }

    function hasGoal() {
        return goal !== undefined
    }

}
