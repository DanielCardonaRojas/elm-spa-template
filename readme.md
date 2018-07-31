# elm-spa-template

This is a starter template to build spa like applications in elm

## Arquitecture

- Module structure like the one Kris Jenkins is encouraged, although initially for small modules view, state and types 
can live in the same file. Once it starts growing create a folder with with State.elm View.elm and Types.elm modules.
Every page goes inside the Pages folder.

- Configuration constants like api urls and others are passed in to the Constants module through a string replacing webpack plugin
instead of using Flags. This really improves on simplifying requests functions avoiding having to pass an extra parameter every time.
These type of configurations are set in the .env file and configured in webpack.config.json.

- Taco pattern is used for globally relevant data. Look at Data.Taco module. 

- Child parent communication through translator patter (smart tags) all child module
expose a normal TEA interface signatures for (view, update, init, subscriptions) it also defines its own Model and Msg types.
The parent module should define a translator which is just a `Child.Msg -> Parent.Msg` mapping, and Cmd.map and Html.map where
ever necesary.

- Using Ports for UI stuff is discouraged so custom events are used in conjuction with custom elements. 

- Styling is done with sass and animations are done with elm-style-animations package.


## Features

- Custom elements with elm modules ready to use (e.g View/GoogleMap.elm with custom element webcomponents/GoogleMap.js):
    - Google Maps: Custom element (Markers are passed int through a property instead of nested html tags)
    - Flatpickr: Custom element Datetime picker (View/Flatpickr.elm)
    - Dropzonejs: Custom element upload files

- SocketIO port module ready to go

- LocalStorage port module

- Toasts can displayed in response to socketio events or can be triggered from within the app using a Echo port module

- Collapsing side bar

- RemoteData pattern

- Setup deployment through surge.sh

- Continiuos integration setup for gitlab

- git hooks setup with husky for automatically running tests on each commits, to install new npm and elm dependencies on pull and merges.

- Hot reloading setup with webpack-dev-server

# Install dependencies

```shell
# Install npm and elm packages
yarn install
elm-package install -y
```

# Run development server

```shell
# Run development server
yarn start
```

# Build and deploy

```shell
# Deploy to surge.sh
yarn build
yarn deploy
```

# Run tests

```shell
elm-test
```

# Directory structure

```text
├── Data
│   ├── Authentication.elm
│   ├── Flags.elm
│   ├── Notification.elm
│   ├── Route.elm
│   ├── Session.elm
│   ├── Taco.elm
│   ├── Theme.elm
│   └── Types.elm
├── Page
│   ├── Home.elm
│   ├── Login.elm
│   └── Signup.elm
├── Ports
│   ├── Echo.elm
│   ├── LocalStorage.elm
│   └── SocketIO.elm
├── Utilities
│   ├── Geolocation.elm
│   ├── Misc.elm
│   └── Parsers.elm
├── View
│   ├── Animations.elm
│   ├── Components.elm
│   ├── Dropzone.elm
│   ├── FlatPickr.elm
│   ├── GoogleMap.elm
│   ├── Spinners.elm
│   └── Toast.elm
├── Application.elm
├── Constants.elm
├── Model.elm
├── Msgs.elm
├── Requests.elm
├── Router.elm
└── View.elm
```

