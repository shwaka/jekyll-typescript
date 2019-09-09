import * as fs from 'fs';

interface SiteObject {
  // incomplete
  site: {
    data: any
  }
}

function test(): void {
  console.log("Message from test!!!");
  const jsonObject = JSON.parse(fs.readFileSync("./site.json", "utf8")) as SiteObject;
  console.log(jsonObject.site.data);
}

test();
