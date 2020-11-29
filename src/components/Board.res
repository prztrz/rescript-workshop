module Styles = {
  open Css

  let status = style(list{marginBottom(px(10))})
  let list = style(list{paddingLeft(px(30))})
  let row = style(list{after(list{clear(both), contentRule(#text(""))})})
}

open Types;

let mapListToElements = (list, transform) =>
  Belt.List.map(list, transform)->Belt.List.toArray->React.array

@react.component
let make = (~board: boardState) => {
  let status = "Next Player: X"
  <div>
    <div className=Styles.status> {React.string(status)} </div>
    {mapListToElements(board, row =>
      <div className=Styles.row> {mapListToElements(row, value => <Square value />)} </div>
    )}
  </div>
}
