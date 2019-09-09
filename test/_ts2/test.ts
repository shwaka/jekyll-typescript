import * as fs from 'fs';

function test(): void {
  console.log("Message from test!!!");
  const jsonObject = JSON.parse(fs.readFileSync("./site.json", "utf8"));
  console.log(jsonObject);
}

test();
