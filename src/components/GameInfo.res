module Styles = {
  open Css

  let container = style(list{marginLeft(px(20))})
  let list = style(list{paddingLeft(px(30))})
}

@react.component
let make = () => {
  <div className=Styles.container>
    <div> {React.null} </div> <ul className=Styles.list> {React.null} </ul>
  </div>
}
