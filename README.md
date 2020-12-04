# Step 3: Interactive board

In previous step we made our board game dynamic so it renders squares according to current board state. Now here comes the fun: we will make board interactive, so it will be actually playable.

If you stuck at any point of doing this step just checkout step-3-final branch to see working solution.

## Add player state to the App component

First game needs to know which player's currently moves. While you may think about some constructors like `Player1` and `Player2`, don't go too far with that. We actually already defined perfect time for describing players: `squareValue`!

In tic tac toe there are always two players. The only important difference between them (from the application perspective) is sign there are going to use to mark the squares they chose during each turn. And I have not played real tic tac toes since primary school, but as far as i remember cross starts, so let's make the state with default value:

```rescript
// App.res

  let (player, setPlayer) = React.useState((_): squareValue => Cross)
```

Note that player is not an option here! Whereas square can be _terra incognita_ without anything filled up, there is always one player's turn. Well at least until we finish the game. But let's worry about this later.

Also if you are confused with `_` of state setter argument, we are going to talk about this later in this step, right now just let's agree it should be there.

Since we defined player already, we can pass it to the board and make the `status` binding more dynamic using string concatenation `++` operator:

```rescript
// Board.res
@react.component
let make = (~board: boardsState, ~player: squareValue) => {
  let status = "Next Player: " ++ (player === Cross ? "X" : "O")
  /* ... */
}
```

## Handle player move

### Switch player

Every move in tic tac toe game should cause two things: update board state and change current player. Let's make a handler starting with latter one as it's trivial:

```rescript
let move = () => {
  setPlayer(player => player === Cross ? Circle : Cross)
}
```

Not much to explain so far, if move is done with cross we are going to update state with circle and conversely.

### Determine square position

Now since we know which player turn is now we could use it to insert proper constructor to our board state 2d list. But at which position? Looks like we cannot tell it from `App` component, and position should be provided as handler parameter.

Unfortunately current `Square` component is not aware its position. Perhaps it is a good idea to define a new prop then:

```rescript
// Square .res

@react.component
let make = (~value: option<squareValue>, ~position: int) => { /* ... */}
```

We will worry with handling this position later. Now reckon that that `Board` is the only component aware of position of every single square. Let's utilize this knowledge to provide props to `Square` components.

In javascript, when mapping an array, we have index exposed as second parameter of the mapping function It is up to us whether we want to use it or not. This not how rescript works. Here **every function has strictly defined number of arguments**. In strongly typed language we cannot just drop second parameter and pretend it does not exists, it's always exist even if we don't want to use it.

But look at our `transform` function in `mapListToElements` it definitely require one argument, otherwise code wouldn't compile. This is because we use `Belt.List.map` function here, and it by definition assumes index is not needed in mapping. But we actually need index, which indicates we need to utilize different method. And there is one just for us `Belt.List.mapWithIndex` which accepts as argument two parameter function, first one is index, and second actual list item. Let's rewrite our helper then:

```rescript
// Board.res

let mapListToElements = (list, transform) =>
  Belt.List.mapWithIndex(list, transform)->Belt.List.toArray->React.array
```

Have you noted that you did not need to change anything? We did not annotate type to `transform` so bucklescript immediately assumed now transform type changed. However since we don't use index in rendering yet now compiler shows you errors when calling the helper. Isn't that convenient? Implementation change immediately forces us to adjust code!

To determine position of every square we need to know row we iterating through and which square in row is currently rendered. Final algorithm is:

```
// pseudocode
let position = LENGTH_OF_ROW * CURRENT_ROW_INDEX + CURRENT_SQUARE_INDEX
```

With this knowledge let's rewrite what `Board` component should return

```rescript
// Board.res

@react.component
let make = (
  ~board: boardState,
  ~player: squareValue,
) => {
  let status = "Next Player: " ++ (player === Cross ? "X" : "O")
  <div>
    <div className=Styles.status> {React.string(status)} </div>

    {
      // transform function in first map has 2 args now, first one (list index) is index of list
      mapListToElements(board, (listIndex, row) =>
      // same thing with transform function  in second mapping
      <div className=Styles.row> {mapListToElements(row, (squareIndex, value) => {
          // and here we use our magic algorithm defined in pseudocode above
          let position = Belt.List.length(row) * listIndex + squareIndex
          <Square value position />
        })} </div>
    )}
  </div>
}
```

### Update state due to position value

So far so good, we can go back to our `move` handler now. According to the algorithm we defined before we have nine squares with position values from `0` to `8`. From this position we need to conlude in which row list on which position is the square we are updating

This is actually simple math. Contrary to js, rescript knows the difference between int and float number. Doing math operation on integers will always result with integer so whatever left after coma during division is dropped. Therefore to get row position we can simply divide square position by number of the rows which is `3`

To get square position we do similar thing but instead of dividing we do modulo operation. Just note that there is no modulo operator in rescript so we need to apply native `mod` function instead.

Once we know which row and which square of this row needs to be updated let's just map the state:

```rescript
// App.res
let move = (position, _) => {
  setBoard(board => {
    let rowIndexToUpdate = position / 3
    let squareIndexToUpdate = mod(position, 3)

    Belt.List.mapWithIndex(board, (rowIndex, row) => {
      if rowIndex === rowIndexToUpdate {
        Belt.List.mapWithIndex(row, (squareIndex, square) => {
          if squareIndex === squareIndexToUpdate {
            Some(player)
          } else {
            square
          }
        })
      } else {
        row
      }
    })
  })

  setPlayer(player => player === Cross ? Circle : Cross)
}
```

Okay... you probably see this whole if-elses blocks do not give us the best readability. In rescript using standalone `if` statement make compiler expects the value returned from if block is `unit`. Once we expect `if` to return something (like we do above), we need to provide else block which returns value of same type. It forces us to keep clean typesafe and consequent code, but ugh, it gets verbose. Fortunately we can refactor a bit using pattern matching instead of if-else block:

```rescript
let move = (position, _) => {
  setBoard(board => {
    let rowIndexToUpdate = position / 3
    let squareIndexToUpdate = mod(position, 3)

    Belt.List.mapWithIndex(board, (rowIndex, row) => {
      switch rowIndex {
      | _ when rowIndex === rowIndexToUpdate =>
        Belt.List.mapWithIndex(row, (squareIndex, square) => {
          switch squareIndex {
          | _ when squareIndex === squareIndexToUpdate => Some(player)
          | _ => square
          }
        })
      | _ => row
      }
    })
  })

  setPlayer(player => player === Cross ? Circle : Cross)
}
```

Wait.. what?
Yeah remember about `_` we used in every state setter so far? Underscored names tell bucklescript that this binding is not going to be used so its value is not relevant. In pattern matching underscored binding match any value provided to `switch`. However in first pattern matching path we used additional condition with [when clause](https://rescript-lang.org/docs/manual/latest/pattern-matching-destructuring#when-clause). This let us check the shape of value and proceed to pattern matching path if condition returns `true`. Since pattern matching stops iterating when it encounter first matching condition, `_ => Row` will match only the rows which do not match first path (so they do not fulfil `rowIndex === rowIndexToUpdate ` condition).

Ok actually we can avoid nesting `switch` by replacing inner statement with ternary operator:

```rescript
// App.res

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
```

### Use handle in Square component

Ok we have working handler, let's drill it down all the way to `Square` component

```rescript
// App.res

@react.component
let make () => {
  /* ... */
  <div className=Styles.container> <Board board player onMove=move /> <GameInfo /> </div>
}
```

```rescript
// Board.res

@react.component
let make = (
  ~board: boardState,
  ~player: squareValue,
  ~onMove: (int) => unit,
) => {
  let status = "Next Player: " ++ (player === Cross ? "X" : "O")
  <div>
    <div className=Styles.status> {React.string(status)} </div>
    {mapListToElements(board, (listIndex, row) =>
      <div className=Styles.row> {mapListToElements(row, (squareIndex, value) => {
          let position = Belt.List.length(row) * listIndex + squareIndex
          <Square value onMove position />
        })} </div>
    )}
  </div>
}
```

It looks like we can simply pass this prop forward to `button` component

```rescript
//Square.res

@react.component
let make = (~value: option<squareValue>, ~onMove: int => unit, ~position: int) => {
  let content = switch value {
  | None => React.null
  | Some(sign) => sign === Cross ? React.string("X") : React.string("O")
  }

  <button className=Styles.container onClick={() => onMove(position)}> {content} </button>
}
```

...or can we? Well you probably already realized that compiler won't be happy with this code. Recall that every function in reason has strictly defined number of arguments, and as you know first argument for every event handler in react is event per se.

We could trivially solve this with adding placeholder:

```rescript
 <button className=Styles.container onClick={(_) => onMove(position)}> {content} </button>
```

But this is not very elegant solution. One thing is we are passing an inline function as `button` prop, another that we have two coupled props (`position` and `onMove`) is `Square` can we make them one. We can. With [currying](https://rescript-lang.org/docs/manual/latest/bind-to-js-function#curry--uncurry).

In rescript every function is curried by default which simply means that if it is called without providing all the arguments another function expecting missing arguments is returned. We can take advantage of that with adding additional parameter to `move` handler.

```rescript
let move = (position, _) => {/*...*/}
```

it is a place for our event, we add it underscored since we do not really need it.

Then in `Board ` component we call `onMove` with `position` as an argument. Without fulfiling second argument `onMove` handler passed to `Square` has type `ReactEvent.Mouse.t => unit`.

```
// Board.res

  <div>
    <div className=Styles.status> {React.string(status)} </div>
    {mapListToElements(board, (listIndex, row) =>
      <div className=Styles.row> {mapListToElements(row, (squareIndex, value) => {
          let position = Belt.List.length(row) * listIndex + squareIndex
          <Square value onMove={onMove(position)} />
        })} </div>
    )}
  </div>
```

now we can use pure handler in our Square

```
// Square.res

@react.component
let make = (~value: option<squareValue>, ~onMove: ReactEvent.Mouse.t => unit) => {
  let content = switch value {
  | None => React.null
  | Some(sign) => sign === Cross ? React.string("X") : React.string("O")
  }

  <button className=Styles.container onClick={onMove}> {content} </button>
}
```

And it works just fine. Congratulations we just created a working board!. Just one las thing: remember to disable button rendered by `Square` when it already has value so players cannot overwrite their squares:

```rescript
 <button disabled={value !== None} className=Styles.container onClick={onMove}> {content} </button>
```

## Conclusion

Ok that's all for this step. In the next one, we gonna program app to stop the game once its finished!
