module StartApp (start, Config, App) where

import Html exposing (Html)
import Task
import Signal exposing (Signal, Address)
import Effects exposing (Effects, Never)


{-| The configuration of an app follows the basic model / update / view pattern
that you see in every Elm program.
-}
type alias Config model action =
  { init : model
  , update : action -> model -> model
  , view : Address action -> model -> Html
  , fx : model -> Effects action
  , inputs : List (Signal action)
  }


{-| An `App` is made up of a couple signals:
-}
type alias App model =
  { view : Signal Html
  , model : Signal model
  , tasks : Signal (Task.Task Never ())
  }


{-| Drive an application. It requires a bit of wiring once you have created an
`App`. It should pretty much always look like this:
-}
start : Config model action -> App model
start config =
  let
    singleton action =
      [ action ]

    -- messages : Signal.Mailbox (List action)
    messages =
      Signal.mailbox []

    -- address : Signal.Address action
    address =
      Signal.forwardTo messages.address singleton

    -- update : List action -> model -> model
    update actions model =
      List.foldl config.update model actions

    -- inputs : Signal (List action)
    inputs =
      Signal.mergeMany (messages.signal :: List.map (Signal.map singleton) config.inputs)

    -- model : Signal model
    model =
      Signal.foldp update config.init inputs

    fx =
      Signal.map config.fx model
  in
    { view = Signal.map (config.view address) model
    , model = model
    , tasks = Signal.map (Effects.toTask messages.address) fx
    }
