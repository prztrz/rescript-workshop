module Styles = {
  open Css

  let container = style(list{display(flexBox), flexDirection(row)})
}

open Types

@react.component
let make = () => {
  let (board, setBoard) = React.useState((_): boardState => list{
    list{None, None, None},
    list{None, None, None},
    list{None, None, None},
  })

  <div className=Styles.container> <Board board /> <GameInfo /> </div>
}
