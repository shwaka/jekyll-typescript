import * as fs from 'fs';

// document.addEventListener("DOMContentLoaded", function(event){
//   const div = document.getElementById("foo");
//   div!.appendChild(document.createTextNode("This text is added by javascript"));
// });

function main() {
  const site = JSON.parse(fs.readFileSync("./site.json", "utf8"));
  const data = site.site.data;
  const data_str = JSON.stringify(data, null, 2)
  console.log(`<div>data: ${data_str}</div>`)
}

main();
