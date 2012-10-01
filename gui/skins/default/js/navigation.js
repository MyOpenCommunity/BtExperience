.pragma library


var ALARM_LOG = 1

var _paths = []

function _init(paths) {
    // inits all possible navigation paths
    paths[ALARM_LOG] = []
    paths[ALARM_LOG][0] = "AlarmLog"
}

// returns a string indicating where to navigate
function getNavigationTarget(current_path, menuLevel) {
    // init, if needed
    if (_paths.length === 0)
        _init(_paths)

    var result = undefined

    if (current_path > 0) // 0 means no menu navigation
        result = _paths[current_path][menuLevel]

    return result
}

