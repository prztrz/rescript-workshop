module Styles = {
  open Css

  let container = style(list{display(flexBox), flexDirection(row)})
}
@react.component
let make = () => <div className=Styles.container> <Board /> <GameInfo /> </div>
