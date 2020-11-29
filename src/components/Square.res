module Styles = {
  open Css

  let container = style(list{
    background(#hex("fff")),
    border(#px(1), #solid, #hex("999")),
    float(#left),
    fontSize(#px(24)),
    fontWeight(#bold),
    lineHeight(#px(34)),
    height(#px(34)),
    marginRight(#px(-1)),
    marginTop(#px(-1)),
    padding(#px(0)),
    textAlign(#center),
    width(#px(34)),
    cursor(#pointer),
    focus(list{outline(#zero, #none, #transparent)}),
  })
}

open Types

@react.component
let make = (~value: option<squareValue>) => {
  let content = switch value {
  | None => React.null
  | Some(sign) => sign === Cross ? React.string("X") : React.string("O")
  }
  <button className=Styles.container> {content} </button>
}
