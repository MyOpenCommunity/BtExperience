.pragma library

/*
  Adapted from:
  http://blogs.korzh.com/progtips/2008/05/28/absolute-coordinates-of-dom-element-within-document.html

  We still don't handle nodes with deprecated "name" attribute.
  We don't handle x positioning.
*/
function getFragmentPositionString(fragment) {
    if (fragment === "")
        return ""

    var s = "var y = 0;" +
            'var element = document.getElementById("' + fragment + '");' +
            "y = element.offsetTop;" +
            "var parentNode = element.parentNode;" +
            "var offsetParent = element.offsetParent;" +
            "while (offsetParent != null) {" +
                "y += offsetParent.offsetTop;" +

                "parentNode = offsetParent.parentNode;" +
                "offsetParent = offsetParent.offsetParent;" +
            "}" +

            "window.fragmentPosition.y = y;"
    return s
}
