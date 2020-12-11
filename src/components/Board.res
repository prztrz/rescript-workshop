module Styles = {
  open Css

  let status = style(list{marginBottom(px(10))})
  let list = style(list{paddingLeft(px(30))})
  let row = style(list{after(list{clear(both), contentRule(#text(""))})})
}

open Types

let mapListToElements = (list, transform) =>
  Belt.List.mapWithIndex(list, transform)->Belt.List.toArray->React.array

@react.component
let make = (
  ~result: option<result>,
  ~board: boardState,
  ~player: squareValue,
  ~onMove: (int, ReactEvent.Mouse.t) => unit,
) => {
  let status = switch (result, player) {
  | (Some(Tie), _) => "Tie"
  | (Some(Win(sign, _)), _) => "Winner " ++ (sign === Cross ? "X" : "O")
  | (None, sign) => "Next player " ++ (sign === Cross ? "X" : "O")
  }
  <div>
    <div className=Styles.status> {React.string(status)} </div>
    {mapListToElements(board, (listIndex, row) =>
      <div className=Styles.row> {mapListToElements(row, (squareIndex, value) => {
          let position = Belt.List.length(row) * listIndex + squareIndex
          <Square value onMove={onMove(position)} />
        })} </div>
    )}
  </div>
}
