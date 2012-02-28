.pragma library

var levelError = 2
var levelWarning = 1
var levelDebug = 0

var currentLogLevel = levelDebug

function logDebug(str) {
    logWithLevel(levelDebug, str);
}

function logWarning(str) {
    logWithLevel(levelWarning, "WARN: " + str);
}

function logError(str) {
    logWithLevel(levelError, "ERR:" + str);
}

function logWithLevel(level, str) {
    if (level >= currentLogLevel)
        console.log(str);
}
