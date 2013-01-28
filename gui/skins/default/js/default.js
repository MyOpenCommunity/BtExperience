// some function to obtain GUI default values

// default home background image file
function getDefaultHomeBg() {
    if (homeProperties.skin === HomeProperties.Clear)
        return "images/background/home.jpg"
    else
        return "images/background/home_dark.jpg"
}
