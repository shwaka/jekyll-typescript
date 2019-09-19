document.addEventListener("DOMContentLoaded", function(event){
  const div = document.getElementById("foo");
  div!.appendChild(document.createTextNode("This text is added by javascript"));
});
