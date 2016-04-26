module RandomGifList (..) where

import Effects exposing (Effects, map, batch, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import RandomGif


-- MODEL


type alias Model =
  { topic : String
  , gifList : List ( Int, RandomGif.Model )
  , uid : Int
  , fx : Effects Action
  }


init : Model
init =
  Model "" [] 0 Effects.none



-- UPDATE


type Action
  = Topic String
  | Create
  | SubMsg Int RandomGif.Action


update : Action -> Model -> Model
update message model =
  case message of
    Topic topic ->
      { model | topic = topic }

    Create ->
      let
        newRandomGif =
          RandomGif.init model.topic
      in
        Model "" (model.gifList ++ [ ( model.uid, newRandomGif ) ]) (model.uid + 1) model.fx

    SubMsg msgId msg ->
      let
        subUpdate (( id, randomGif ) as entry) =
          if id == msgId then
            ( id, RandomGif.update msg randomGif )
          else
            entry
      in
        { model | gifList = List.map subUpdate model.gifList }



-- FX


fx : Model -> Effects Action
fx model =
  let
    subFx ( id, randomGif ) =
      Effects.map (SubMsg id) (RandomGif.fx randomGif)
  in
    Effects.batch (model.fx :: (List.map subFx model.gifList))



-- VIEW


(=>) =
  (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div
    []
    [ input
        [ placeholder "What kind of gifs do you want?"
        , value model.topic
        , onEnter address Create
        , on "input" targetValue (Signal.message address << Topic)
        , inputStyle
        ]
        []
    , div
        [ style [ "display" => "flex", "flex-wrap" => "wrap" ] ]
        (List.map (elementView address) model.gifList)
    ]


elementView : Signal.Address Action -> ( Int, RandomGif.Model ) -> Html
elementView address ( id, model ) =
  RandomGif.view (Signal.forwardTo address (SubMsg id)) model


inputStyle : Attribute
inputStyle =
  style
    [ ( "width", "100%" )
    , ( "height", "40px" )
    , ( "padding", "10px 0" )
    , ( "font-size", "2em" )
    , ( "text-align", "center" )
    ]


onEnter : Signal.Address a -> a -> Attribute
onEnter address value =
  on
    "keydown"
    (Json.customDecoder keyCode is13)
    (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
  if code == 13 then
    Ok ()
  else
    Err "not the right key code"
