module Styles = {
  open Css

  let base = style(list{position(#absolute), backgroundColor(hex("ff0000"))})

  let verticalBase = style(list{top(px(35)), width(px(5)), height(px(99))})
  let verticalFirst = style(list{left(px(22))})
  let verticalSecond = style(list{left(px(56))})
  let verticalThird = style(list{left(px(88))})

  let horizontalBase = style(list{left(px(9)), width(px(98)), height(px(5))})
  let horizontalFirst = style(list{top(px(49))})
  let horizontalSecond = style(list{top(px(82))})
  let horizontalThird = style(list{top(px(115))})

  let diagonalBase = style(list{top(px(17)), left(px(56)), width(px(5)), height(px(136))})
  let diagonalFirst = style(list{transform(#rotate(deg(-45.0)))})
  let diagonalSecond = style(list{transform(#rotate(deg(45.0)))})
}

open Types

@react.component
let make = (~line: line) => {
  let getVariantClassname = (idx, first, second, third) => {
    switch idx {
    | 0 => first
    | 1 => second
    | 2 => third
    | _ => raise(Not_found)
    }
  }

  let appendToBase = Cn.append(Styles.base)

  let className = switch line {
  | Vertical(idx) =>
    appendToBase(Styles.verticalBase)->Cn.append(
      getVariantClassname(idx, Styles.verticalFirst, Styles.verticalSecond, Styles.verticalThird),
    )
  | Horziontal(idx) =>
    appendToBase(Styles.horizontalBase)->Cn.append(
      getVariantClassname(
        idx,
        Styles.horizontalFirst,
        Styles.horizontalSecond,
        Styles.horizontalThird,
      ),
    )
  | Diagonal(idx) =>
    appendToBase(Styles.diagonalBase)->Cn.append(
      getVariantClassname(idx, Styles.diagonalFirst, Styles.diagonalSecond, ""),
    )
  }

  <div className />
}
