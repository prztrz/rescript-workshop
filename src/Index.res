// Entry point

// open webapi for comfortable dom manipulations
open Webapi

// added  bs-webapi for powerful DOM manipulations
@bs.val external document: Dom.Document.t = "document"

// We're using raw DOM manipulations here, to avoid making you read
// ReasonReact when you might precisely be trying to learn it for the first
// time through the examples later.

let appendContainer = container => {
  let htmlDocument = Belt.Option.getExn(Dom.Document.asHtmlDocument(document))
  let body = Belt.Option.getExn(Dom.HtmlDocument.body(htmlDocument))

  Dom.Element.appendChild(container, body)
}

let makeContainer = () => {
  let container = Dom.Document.createElement("div", document)
  Dom.Element.setClassName(container, "container")

  appendContainer(container)

  container
}

ReactDOMRe.render(<App />, makeContainer())
