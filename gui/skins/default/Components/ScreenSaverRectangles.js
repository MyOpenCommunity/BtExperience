var hexDigits = ['0', '1', '2', '3', '4', "5","6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
function generateProperties(screenWidth, screenHeight) {
    var hex1 = hexDigits[Math.floor(Math.random() * hexDigits.length)]
    var hex2 = hexDigits[Math.floor(Math.random() * hexDigits.length)]
    var hex3 = hexDigits[Math.floor(Math.random() * hexDigits.length)]
    var hex4 = hexDigits[Math.floor(Math.random() * hexDigits.length)]
    var hex5 = hexDigits[Math.floor(Math.random() * hexDigits.length)]
    var hex6 = hexDigits[Math.floor(Math.random() * hexDigits.length)]
    var color = "#" + hex1 + hex2 + hex3 + hex4 + hex5 + hex6
    var width = Math.random() * screenWidth / 4 + 30
    var height = Math.random() * screenHeight / 4 + 30
    var x = Math.random() * screenWidth - width / 2
    var y = Math.random() * screenHeight - height / 2
    return {"color": color, "width": width, "height": height, "x": x, "y": y}
}
