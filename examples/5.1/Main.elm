module Main (..) where

import Effects exposing (Never, Effects)
import RandomGif exposing (init, update, view, fx)
import StartApp
import Task


app =
  StartApp.start
    { init = init "funny cats"
    , update = update
    , fx = fx
    , view = view
    , inputs = []
    }


main =
  app.view


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
