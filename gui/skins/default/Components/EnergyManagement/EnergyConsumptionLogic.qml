import QtQuick 1.1

QtObject {
    property variant monthConsumptionItem: undefined
    property variant goal: monthConsumptionItem !== undefined ? monthConsumptionItem.consumptionGoal : 0.0
    property variant consumption: monthConsumptionItem !== undefined ? monthConsumptionItem.value : 0.0

    function maxSize(referenceSize) {
        return referenceSize * .95
    }

    function idealGoalSize(referenceSize) {
        return referenceSize * .9
    }

    // the size of goal line. Can be as the "ideal" goal size or less if
    // the consumption size is greater than the reference size.
    function goalSize(referenceSize) {
        if (goal === undefined) // the goal line is not shown at all, using hasGoal()
            return 0.0

        var size = consumption / goal * idealGoalSize(referenceSize)
        if (size > maxSize(referenceSize))
            return goal / consumption * idealGoalSize(referenceSize)
        else
            return idealGoalSize(referenceSize)
    }

    // the size of the consumption bar. It is a value related to the goal
    // size, and it has a maximum value (in the latter case, the goal size
    // is decreased proportionally).
    function getConsumptionSize(referenceSize) {
        if (consumption === undefined)
            return 0

        if (goal !== undefined) {
            var size = consumption / goal * idealGoalSize(referenceSize)
            return Math.min(size, maxSize(referenceSize))
        }
        else {
            // a very simplified representation of the consumption size,
            // proportionally to the days elapsed in the month.
            // TODO: find a better representation!
            var d = new Date()
            return d.getDate() / 30 * idealGoalSize(referenceSize)
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
