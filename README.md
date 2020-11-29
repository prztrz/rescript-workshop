# Step 2: Dynamic board

Let's take a look at our components among others we have defined:

- App
- Board
- Square

Right now they are just styled components which render static html code. Now we are going to make them dynamic. If you encounter any troubles when coding this step just checkout to `step-2-final` branch to see working solution for this step.

## Make App stateful

`App` component requires state to control the board. Let's take a moment to think what kind of data do we need to represent every square of the board.

In our app crosses and circles filling the board squares are represented by simple strings: `"X"` or `"O"`. It might be tempting then to make `Square` component excepting `string` type as a prop. However this is probably not the best idea as string is not restricted to these two simple characters. Fortunately rescript provides us very powerful [variant type](https://rescript-lang.org/docs/manual/latest/variant) which gets one of defined options values. Now we can use it to define `squareValue` type:

```rescript
type squareValue = "X" | "O"
```

Nice... or is it? Well actually this is still not the best option we have here. Ok we defined possible values of the square. But what if we would want to replace the characters with some fancy icons in the future? How would we possibly define proper svg icon into rescript type? Well we cannot. But what we can do is to utilize true power of `variant` and define it with constructors. Constructors are special variant possibilities which we define by naming them with capital letters. Name is absolutely up to us, so let's open `Types.res` file to create `squareValue` variant with the options square really can get.

```rescript
// Types.res

type squareValue = Cross | Circle
```

Isn't that wonderful? We just defined that every square on the board can get one of two possible states `Cross` or `Circle` exactly like they do in tic tac toe game! Let's keep this in mind for a moment, later in this step we are going to program `Square` component to render proper value depending on the constructor it gets.

But first let's get back to our board. Whereas each square can be simply either `Cross` or `Cricle` boards has nine squares in three rows with three squares each. This is exactly how its state should be represented. Lets make two dimensional list to keep subsequent row data in `boardState` type:

```rescript
// Types.res

type squareValue = Cross | Circle
type boardState = list<list<squareValue>>
```

Well this looks good but I guess we forgot about one possible square state: every square is empty before it gets fulfilled with cross or circle! Should we extend `squareValue` type then? We could, but there is a better solution: rescript gives as a special type just for this kind of situation: [option](https://rescript-lang.org/docs/manual/latest/api/belt/option). Option is specialized variant defined as:

```rescript
type option<'a> = Some<'a> | None
```

It's much easier that it may look! Think about `'a` much like you think about generic types in typescript. It is a bit like placeholder which allows you to pass the value while you defining any structure of `option` type. This value is then passed to `Some` constructor as argument and can be pulled out from it later! Alternatively if we do not have this value, option can always return `None` constructor which clearly indicates that value does not exist. So our final `Types.res` should look like this:

```rescript
// Types.res

type squareValue = Cross | Circle
type boardState = list<list<option<squareValue>>>
```

We have all types we need for now, let go to `App` component to make it stateful. Types are defined, so to be sure `App` is aware of them let's open the module:

```rescript
// App.res

module Styles = {
  open Css

  let container = style(list{display(flexBox), flexDirection(row)})
}

open Types

@react.component
let make = () => {
  <div className=Styles.container> <Board /> <GameInfo /> </div>
}
```

Cool now we need to provide initial state with good old `useState` hook:

```Rescript
// App.res

@react.component
let make = () => {
  let (board, setBoard) = React.useState((_): boardState => list{
    list{None, None, None},
    list{None, None, None},
    list{None, None, None},
  })

  <div className=Styles.container> <Board board /> <GameInfo /> </div>
}
```

**Note** `(board, setBoard)` is destructuring of special rescript structure called a tuple. It is returned by `useState`, but don't worry about it now we will get to the tuples later).

Pretty fair initial state, as no square should be fulfilled initially. We used `boardState` type in state initialization function just for documentation reason! Actually rescript does not require it as it can infer type from the value this function returns. Also note that we already pass `board` to `Board` component. Funny fact props in rescript are [punned](https://rescript-lang.org/docs/manual/latest/jsx#punning) which means if the binding and prop name are the same we do not need to explicitly use `=` operator to pass the value. Pretty much like with js objects!

## Make Board component dynamic

Since we have board state representation already and we pass it to `Board` first we need to define props on `Board` component. In rescript using `@react.component` annotation we define props as the [labeled arguments](https://rescript-lang.org/docs/manual/latest/bind-to-js-function#labeled-arguments) of `make` function:

```rescript
// Board.res

open Types;
let make(~board: boardState) => {/*...*/}
```

Let's take a look at the small `mapListToElements` helper here. What it does is using `Belt` library to map provided `list` according to `transform` method to list of react elements and then passing result forward with pipe `->` operator to transform it to array and then to `React.array` which is proper type for jsx embedded arrays. We can use this to map our state list.

```rescript
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
```

Note you will get react missing key standard warning, but it's not important in this tutorial. You could probably replace the given helper with `Belt.List.mapWithIndex` function and pass indexes as keys if you want to be a purist.

Here we have created board to pass proper values to rendered `Square` components let's take a look at them now.

## Display values in Square

As you reckon `Square` expects to get `option<squareValue>` type which eventually tells it if it shall display cross circle or nothing. But the problem here is that constructors are not real things, they are not renderable - it is just an abstraction we need to utilize to render actual data. For that we can use the most powerful feature of rescript: [pattern matching](https://rescript-lang.org/docs/manual/latest/pattern-matching-destructuring). Let's look:

```rescript
// Square.res

open Types

@react.component
let make = (~value: option<squareValue>) => {
  let content = switch value {
  | None => ""
  | Some(Cross) => "X"
  | Some(Circle) => "O"
  }
  <button className=Styles.container> {content} </button>
}
```

That's it! We used `switch` statement to iterate towards possible values of `value` prop and provide instruction what to do with every of them! But you probably already realized that this code want compile. Actually the problem here is react elements which render html nodes do not accept pure strings as children. Rather they requires another react element such as (in this case) `React.string` we could make a super quick fix in one line:

```rescript
<button className=Styles.container> {React.string(content)} </button>
```

And it is going to work. But I am still not 100% happy with this code. Do we really need an empty string in case of `None`? Well whereas empty strings are pretty common in wild wild west world of javascript, they are totally avoidable in rescript. Let's remember that every path of pattern matching is supposed to return the same type. So `content` instead of string should return a proper react element

```rescript
// Square.res

open Types

@react.component
let make = (~value: option<squareValue>) => {
  let content = switch value {
  | None => React.null
  | Some(Cross) => React.string("X")
  | Some(Circle) => React.string("O")
  }
  <button className=Styles.container> {content} </button>
}
```

Wow we're almost there now! Just one more thing: as we do not really need this boiler plate with repeating `Some` statement in pattern matching. Here we defined strict rules what to do in strict cases, but we can take dynamic value of `Some` argument and adjust path accordingly. Just use lowercased binding name for dynamic value instead of defined uppercased constructor name:

```rescript
// Square.res

open Types

@react.component
let make = (~value: option<squareValue>) => {
  let content = switch value {
  | None => React.null
  | Some(sign) => sign === Cross ? React.string("X") : React.string("O")
  }
  <button className=Styles.container> {content} </button>
}
```

## Conclusion

We just created dynamic board which is controlled by App state, for now we don't serve any events so our tic tac toe is still not playable but it works - if you don't believe just try to substitute any `None` in `App.res` state with `Some(Circle)` or `Some(Cross)` to see result! In the next step we are going to make board interactive
