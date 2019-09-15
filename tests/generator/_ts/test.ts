import * as fs from 'fs';
import {JSDOM} from 'jsdom';
import {foo} from './lib';

function get_data(): string {
  const site = JSON.parse(fs.readFileSync("./site.json", "utf8"));
  const data = site.site.data;
  const data_str = JSON.stringify(data, null, 2);
  return data_str;
}

function main() {
  const dom = new JSDOM();
  const document = dom.window.document;

  const div = document.createElement("div");
  div.appendChild(document.createTextNode("This is a div!"));
  document.body.appendChild(div);

  const data_str = get_data();
  const pre = document.createElement("pre");
  pre.appendChild(document.createTextNode(data_str));
  document.body.appendChild(pre);

  // console.log(`<div style="color: blue;">data: ${data_str}</div>`);
  console.log(document.body.innerHTML);

  foo(document);
}

main();
