'use strict';

var React = require("react");
var ReactDom = require("react-dom");
var Belt_Option = require("bs-platform/lib/js/belt_Option.js");
var Caml_option = require("bs-platform/lib/js/caml_option.js");
var App$RescriptWorkshop = require("./components/App.bs.js");
var Webapi__Dom__Document = require("bs-webapi/src/Webapi/Dom/Webapi__Dom__Document.bs.js");

function appendContainer(container) {
  var htmlDocument = Belt_Option.getExn(Webapi__Dom__Document.asHtmlDocument(document));
  var body = Belt_Option.getExn(Caml_option.nullable_to_opt(htmlDocument.body));
  body.appendChild(container);
  
}

function makeContainer(param) {
  var container = document.createElement("div");
  container.className = "container";
  appendContainer(container);
  return container;
}

ReactDom.render(React.createElement(App$RescriptWorkshop.make, {}), makeContainer(undefined));

exports.appendContainer = appendContainer;
exports.makeContainer = makeContainer;
/*  Not a pure module */
