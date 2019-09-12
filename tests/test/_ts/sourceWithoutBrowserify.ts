document.addEventListener("DOMContentLoaded", function(){
  const div: HTMLElement = document.getElementById("without-browserify")!;
  div.appendChild(document.createTextNode("Test without browserify successed!"));
})
