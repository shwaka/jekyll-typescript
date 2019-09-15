export function foo(document: Document): void {
  const div = document.createElement("div");
  const span = document.createElement("span");
  span.appendChild(document.createTextNode("This is a span."));
  div.appendChild(span);
  console.log(div.innerHTML);
}
