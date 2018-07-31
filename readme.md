# elm-spa-template

This is a starter template to build a spa like application in elm
it uses the following approach: 

- Module structure like the one Krisajenkins is encouraged, although initially for small modules view, state and types 
can live in the same file. Once it starts growing create a folder with with State.elm View.elm and Types.elm modules.
Every page goes inside the Pages folder.

- Configuration constants like api urls and others are passed in to the Constants module through a string replacing webpack plugin
instead of using Flags. This really improves on simplifying requests functions avoiding having to pass an extra parameter every time.
These type of configurations are set in the .env file and configured in webpack.config.json.

- Child parent communication through translator patter (smart tags) all child module
expose a normal TEA interface view, update, init, subscriptions it also defines its own Model and Msg types.
The parent module should define a translator which is just a `Child.Msg -> Parent.Msg` mapping, and Cmd.map and Html.map where
ever necesary.


- Third party widgets are rapped in custom elements, this template provide a GoogleMaps, Flatpickr date time picker
and Dropzonejs custom element.

- Menu items are selected base on a list zipper data structure


## Features

- Custom elements with elm module ready to use:
    - Google Maps: Custom element (Markers are passed int through a property instead of nested html tags)
    - Flatpickr: Custom element Datetime picker
    - Dropzonejs: Custom element upload files

- SocketIO port module ready to go

- LocalStorage port module

- Toasts can displayed in response to socketio events or can be triggered from within the app using a Echo port module

- Collapsing side bar

- RemoteData pattern

- Setup deployment through surge.sh

- Continues integration setup for gitlab

- git hooks setup with husky for automatically run test on commits install new npm and elm dependencies on pull and merges.

- Hot reloading setup with webpack-dev-server

# Install dependencies

```shell
# If you don't have yarn
brew install yarn
yarn global add elm 
# Alternatively sudo npm install -g elm --unsafe-perm=true

# Install npm and elm packages
yarn install
elm-package install -y
```

# Run development server

```shell
# Make shure you edit the .env file to set the api base url and version.
# Run development server
yarn start
```

# Build and deploy

```shell
yarn build

# Deploy to surge.sh
yarn deploy
```

# Run tests

```shell
yarn global add elm-test
elm-test
```
