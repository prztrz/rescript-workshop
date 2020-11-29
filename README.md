# Step 1: Initial setup

In this step we gonna setup our rescript react app. Before start make sure your text editor supports rescript syntax. I used vscode with [rescript-vscode](https://marketplace.visualstudio.com/items?itemName=chenglou92.rescript-vscode) plugin. Feel free to check a [list of available plugins](https://rescript-lang.org/docs/manual/latest/editor-plugins) on rescript docs.

All the terminal commands listed below assumed using yarn as dependency manager. But it will work with npm too.

If you encounter any problems feel free to checkout `step-1-final` branch to get working solution

```bash
git checkout step-1-final
```

## Install bucklescript globally

First things first: you cannot work with rescript if you do not have rescript compiler. Bucklescript is going to compile your code to nice and readable javascript. Let's install it globally

```bash
yarn global add bs-platform
```

## Clone repo and instal dependencies

Once you have bsb-platform installed let's clone this repo and install dependencies:

```bash
git clone https://github.com/prztrz/rescript-workshop.git
yarn install
```

We're almost ready to start development! Now run bucklescript compiler in watch mode with:

```bash
yarn start
```

Now in separate terminal let's run our dev server

```bash
yarn server
```

Now open http://localhost:8000 to see your app

## Create app container

If you take a look at `index.html` file you'll see there's not much in there. Certainly there is no a proper container to render react app to. No problem though. Let's create one programatically using typescript.

### Add bs-webApi

Since we are going to mess with web api here let's install one more module: community driven [bs-webapi](https://reasonml-community.github.io/bs-webapi-incubator/api/Webapi/) which provides set of methods for powerful DOM manipulations.

```bash
yarn add bs-webapi
```

We also need to make bucklescript aware of this module. So let's add it to bs-dependencies in `bsconfig.json` file.

```json
  "dependencies": {
    "bs-webapi": "^0.19.1",
    "bs-css-emotion": "^2.2.0",
    "react": "^16.8.1",
    "react-dom": "^16.8.1",
    "reason-react": ">=0.7.1"
  },
```

### Use js document

Now let's start coding. Rescript natively is not aware of web apis like `document` to bring native js features we gonna use [external binding](https://rescript-lang.org/docs/manual/latest/external) in our `index.res` file

```rescript
@bs.val external document: Webapi.Dom.Document.t = "document"
```

`@bs.val external` tells bucklescript we are going to use raw js feature
`document` is a binding name - you can name it however you want though.
since `document` is not native part of rescript we need to type it properly, fortunatelly bs-webapi does this job for us providing `Webapi.Dom.Document.t` type.
Finally we need to point out what we actually gonna take from js. This the magic `"document"` string at the end of line.

### Create container element

Ok now we have everything we need to create proper html element. Let's create `makeContainer` function

```rescript
let makeContainer = () => {
  let container = Webapi.Dom.Document.createElement("div", document)

  container
}
```

If you wonder what's the last line for - it's the [implicit return](https://rescript-lang.org/docs/manual/latest/overview#blocks-1). There is no such thing as `return` statement in rescript. Instead it will always return last line of the block.

Another Important lesson here: as a functional language rescript will not let you mutate original document. Instead you will need to provide an instance as an argument and `createElement` will return the new document instance for you. Don't worry though! It will still compile to proper js code. Actually your output `index.bs.js` file should look like this at the moment:

```js
function makeContainer(param) {
  var container = document.createElement("div");
  return container;
}
```

### Append container

Once we create a `div` we should append it to document body, here I created `appendContainer` function

```rescript
let appendContainer = container => {
  let htmlDocument = Belt.Option.getExn(Webapi.Dom.Document.asHtmlDocument(document))
  let body = Belt.Option.getExn(Webapi.Dom.HtmlDocument.body(htmlDocument))

  Dom.Element.appendChild(container, body)
}
```

It might look confusing at the first glance let's look closer then:
`Webap.Dom.Document` provides an api with set of method for manipulating document. Since we need actual html document here we need to get it with `asHtmlDocument` method. However this method actually returns an [option type](https://rescript-lang.org/docs/manual/latest/api/belt/option). To extract actual document from option there is additional step needed. Here I used [getExn](https://rescript-lang.org/docs/manual/latest/api/belt/option#getexn) metod provided by [Belt](https://rescript-lang.org/docs/manual/latest/api/belt) standard library. It's going to get value from option or throw an exception if option value is `None`.

Then we get document's body in similar fashion. Finally we use `appendChild` method to append our container into body. Now we just need to use this function as side effect in previously created `makeContainer`

```rescript
let makeContainer = () => {
  let container = Webapi.Dom.Document.createElement("div", document)

  appendContainer(container)

  container
}
```

### Render App component in container

At this point we created a method which creates container div and adds it to document's body. Let's use it to render our App. `App` component is already defined in `src/components`. Since every file in rescript project is a module by default we can use it straight orward. For react-dom render we utilize `ReacDomRe` module.

```rescript
ReactDOMRe.render(<App />, makeContainer())
```

...and _voila_! Now you should see the `App` component in your browser.

### Code cleanup

You may realized that there is quite a boilerplate with repeating `Webapi` all the time we need it. We can remove this by [opening](https://rescript-lang.org/docs/manual/latest/module#opening-a-module) the package at the begining of the file. Simply use `open Webapi` and then your code should look like that eventually:

```rescript
open Webapi

@bs.val external document: Dom.Document.t = "document"


let appendContainer = container => {
  let htmlDocument = Belt.Option.getExn(Dom.Document.asHtmlDocument(document))
  let body = Belt.Option.getExn(Dom.HtmlDocument.body(htmlDocument))

  Dom.Element.appendChild(container, body)
}

let makeContainer = () => {
  let container = Dom.Document.createElement("div", document)
  Dom.Element.setClassName(container, "container")

  appendContainer(container)

  container
}

ReactDOMRe.render(<App />, makeContainer())
```

That's it for the first step. You just created app container and rendered first react component of the tree. Let's go to the next step.
