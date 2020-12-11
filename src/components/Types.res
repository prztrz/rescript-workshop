type squareValue = Cross | Circle
type boardState = list<list<option<squareValue>>>

type line =
  | Horziontal(int)
  | Vertical(int)
  | Diagonal(int)

type winner = (squareValue, line)

type result =
  | Tie
  | Win(winner)
