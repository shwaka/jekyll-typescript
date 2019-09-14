"use strict";
document.addEventListener("DOMContentLoaded", function (event) {
    var div = document.getElementById("foo");
    div.appendChild(document.createTextNode("This text is added by javascript"));
});
