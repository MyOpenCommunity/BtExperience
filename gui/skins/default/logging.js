.pragma library

var levelError = 2
var levelWarning = 1
var levelDebug = 0

var currentLogLevel = levelDebug

function logDebug(str) {
    logWithLevel(levelDebug, str);
}

function logWarning(str) {
    logWithLevel(levelWarning, str);
}

function logError(str) {
    logWithLevel(levelError, str);
}

function logWithLevel(level, str) {
    if (level >= currentLogLevel)
        console.log(str + " ");
}
