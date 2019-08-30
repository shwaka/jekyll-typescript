document.addEventListener("DOMContentLoaded", function(){
  const div: HTMLElement = document.getElementById("baz")!;
  div.appendChild(document.createTextNode("abcdef"));
})
