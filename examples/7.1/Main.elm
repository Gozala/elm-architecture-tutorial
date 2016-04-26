module Main (..) where

import Effects exposing (Never)
import RandomGifList exposing (init, update, view, fx)
import StartApp
import Task


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , fx = fx
    , inputs = []
    }


main =
  app.view


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
