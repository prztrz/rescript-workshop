module Styles = {
  open Css

  let container = style(list{display(flexBox), flexDirection(row)})
}

open Types

@react.component
let make = () => {
  let (player, setPlayer) = React.useState((_): squareValue => Cross)

  let (board, setBoard) = React.useState((_): boardState => list{
    list{None, None, None},
    list{None, None, None},
    list{None, None, None},
  })

  let move = (position, _) => {
    setBoard(board => {
      let rowIndexToUpdate = position / 3
      let squareIndexToUpdate = mod(position, 3)

      Belt.List.mapWithIndex(board, (rowIndex, row) => {
        switch rowIndex {
        | _ when rowIndex === rowIndexToUpdate =>
          Belt.List.mapWithIndex(row, (squareIndex, square) =>
            squareIndex === squareIndexToUpdate ? Some(player) : square
          )
        | _ => row
        }
      })
    })

    setPlayer(player => player === Cross ? Circle : Cross)
  }

  <div className=Styles.container> <Board board player onMove=move /> <GameInfo /> </div>
}
