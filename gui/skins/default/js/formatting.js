
// Return a string representing the number passed as first argument.
// The fillChar argument is the char used to fill the string.
function padNumber(number, length, fillChar) {
    if (fillChar === undefined)
        fillChar = "0"

    var out = "" + number;
    while (out.length < length) {
        out = fillChar + out;
    }
    return out;
}
