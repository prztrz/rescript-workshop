module Styles = {
  open Css

  let container = style(list{display(flexBox), flexDirection(row)})
  let resetButton = style(list{height(px(30)), cursor(#pointer)})
}

open Types

let lines = list{
  list{(0, 1, 2), (3, 4, 5), (6, 7, 8)},
  list{(0, 3, 6), (1, 4, 7), (2, 5, 8)},
  list{(0, 4, 8), (2, 4, 6)},
}

let getLine = (lineTypeIndex, lineIndex) => {
  switch (lineTypeIndex, lineIndex) {
  | (0, index) => Horziontal(index)
  | (1, index) => Vertical(index)
  | (2, index) => Diagonal(index)
  | _ => raise(Not_found)
  }
}

let isLine = (board, lineTuple) => {
  let (a, b, c) = lineTuple

  let getElement = Belt.List.get(board)
  if getElement(a) === getElement(b) && getElement(b) === getElement(c) {
    true
  } else {
    false
  }
}

let rec checkLine = (lineTupleList, board, position) => {
  let (lineTypeIndex, lineIndex) = position

  switch lineTupleList {
  | list{} => None
  | list{head, ...tail} =>
    isLine(board, head)
      ? Some(getLine(lineTypeIndex, lineIndex))
      : checkLine(tail, board, (lineTypeIndex, lineIndex + 1))
  }
}

let rec checkWinner = (lines, board, player, index) => {
  switch lines {
  | list{} => None
  | list{head, ...tail} => {
      let currentLine = checkLine(head, board, (index, 0))

      switch currentLine {
      | None => checkWinner(tail, board, player, index + 1)
      | Some(line) => Some((player, line))
      }
    }
  }
}

let checkTie = board => Belt.List.every(board, item => item !== None) ? Some(Tie) : None

let checkResult = (lines, board, player, index) => {
  switch checkWinner(lines, board, player, index) {
  | Some(winner) => Some(Win(winner))
  | None => checkTie(board)
  }
}

let updateBoard = (position, player, board) => {
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
}

let initialBoard: boardState = list{
  list{None, None, None},
  list{None, None, None},
  list{None, None, None},
}

@react.component
let make = () => {
  let (player, setPlayer) = React.useState((_): squareValue => Cross)
  let (result, setResult) = React.useState((_): option<result> => None)
  let (board, setBoard) = React.useState((_): boardState => initialBoard)

  let move = (position, _) => {
    let updatedBoard = updateBoard(position, player, board)
    setBoard(_ => updatedBoard)
    setPlayer(player => player === Cross ? Circle : Cross)
    setResult(_ => checkResult(lines, Belt.List.flatten(updatedBoard), player, 0))
  }

  let handleReset = _ => {
    setBoard(_ => initialBoard)
    setPlayer(_ => Cross)
    setResult(_ => None)
  }

  <div className=Styles.container>
    <Board board player result onMove=move />
    {result === None
      ? React.null
      : <button className=Styles.resetButton onClick=handleReset> {React.string("reset")} </button>}
    {switch result {
    | Some(Win(_, line)) => <Line line />
    | _ => React.null
    }}
  </div>
}
