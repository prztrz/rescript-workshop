module Styles = {
  open Css

  let status = style(list{marginBottom(px(10))})
  let list = style(list{paddingLeft(px(30))})
  let row = style(list{after(list{clear(both), contentRule(#text(""))})})
}

let mapListToElements = (list, transform) =>
  Belt.List.map(list, transform)->Belt.List.toArray->React.array

@react.component
let make = () => {
  let status = "Next Player: X"
  <div>
    <div className=Styles.status> {React.string(status)} </div>
    <div className=Styles.row>
      {mapListToElements(list{0, 1, 2}, idx => <Square key={string_of_int(idx)} />)}
    </div>
    <div className=Styles.row>
      {mapListToElements(list{3, 4, 5}, idx => <Square key={string_of_int(idx)} />)}
    </div>
    <div className=Styles.row>
      {mapListToElements(list{6, 7, 8}, idx => <Square key={string_of_int(idx)} />)}
    </div>
  </div>
}
