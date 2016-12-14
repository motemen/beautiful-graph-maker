port module Main exposing (..)

import Html exposing (Html)
import Svg exposing (svg, defs, text_, g, line, marker, text)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)
import Navigation
import QueryString exposing (one, string)


main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


port prompt : String -> Cmd msg


port promptResult : ((String, String) -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
  promptResult SetYLabel


init : Navigation.Location -> (Model, Cmd Msg)
init location =
  ( modelFromQueryString location.search
  , Cmd.none
  )


type alias Model =
  { yLabelUpper : String
  , yLabelLower : String
  , lineRising : Bool
  }


type Msg
  = UrlChange Navigation.Location
  | RequestYLabelUpper
  | RequestYLabelLower
  | SetYLabel (String, String)
  | ToggleTrend


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UrlChange location ->
      init location
    RequestYLabelUpper ->
      ( model, prompt "Upper" )
    RequestYLabelLower ->
      ( model, prompt "Lower" )
    _ ->
      let newModel =
        case msg of
          ToggleTrend ->
            { model | lineRising = not model.lineRising }
          SetYLabel ("Upper", label) ->
            { model | yLabelUpper = label }
          SetYLabel ("Lower", label) ->
            { model | yLabelLower = label }
          _ ->
            model
      in
        ( newModel, Navigation.modifyUrl (queryStringFromModel newModel) )


modelFromQueryString : String -> Model
modelFromQueryString search =
    let qs = QueryString.parse search
    in
      Model (qs |> QueryString.one QueryString.string "y2" |> Maybe.withDefault "😊")
            (qs |> QueryString.one QueryString.string "y1" |> Maybe.withDefault "🙁")
            (qs |> QueryString.one QueryString.int     "a" |> Maybe.withDefault 1 |> (\a -> a /= -1))

queryStringFromModel : Model -> String
queryStringFromModel model =
  QueryString.empty
    |> QueryString.add "a"  (if model.lineRising then "1" else "-1")
    |> QueryString.add "y1" model.yLabelLower
    |> QueryString.add "y2" model.yLabelUpper
    |> QueryString.render


view : Model -> Html Msg
view model =
  svg [ id "canvas", viewBox "-50 0 450 450" ]
    [ defs []
      [ marker
          [ id "arrow-head"
          , orient "auto"
          , refX "0"
          , refY "5"
          , viewBox "0 0 10 10"
          ]
        [ Svg.path [ d "M 0 0 L 10 5 L 0 10 z" ] [] ]
      ]
    , text_
        [ dominantBaseline "middle"
        , dx "-50"
        , style "font-size: 50px"
        , textAnchor "middle"
        , textLength "100"
        , x "50"
        , y "100"
        , onClick RequestYLabelUpper
        ]
        [ text model.yLabelUpper ]
    , text_
        [ dominantBaseline "middle"
        , dx "-50"
        , style "font-size: 50px"
        , textAnchor "middle"
        , textLength "100"
        , x "50"
        , y "300"
        , onClick RequestYLabelLower
        ]
        [ text model.yLabelLower ]
    , g
        [ style "font-family: 'Helvetica Neue', sans-serif; font-size: 24px"
        ]
        [ text_
            [ dx "0"
            , dy "40"
            , textAnchor "middle"
            , x "100"
            , y "350"
            ]
          [ text "Before" ]
        , text_
            [ dx "10"
            , dy "40"
            , textAnchor "middle"
            , x "300"
            , y "350"
            ]
          [ text "After" ]
        ]
    , line
        [ id "line-up"
        , markerEnd "url(#arrow-head)"
        , stroke "black"
        , strokeWidth "10"
        , display (if model.lineRising then "" else "none")
        , onClick ToggleTrend
        , x1 "100"
        , x2 "300"
        , y1 "300"
        , y2 "100"
        ]
        []
    , line
        [ id "line-down"
        , markerEnd "url(#arrow-head)"
        , stroke "black"
        , strokeWidth "10"
        , display (if model.lineRising then "none" else "")
        , onClick ToggleTrend
        , x1 "100"
        , x2 "300"
        , y1 "100"
        , y2 "300"
        ]
        []
    , line
        [ stroke "black"
        , strokeWidth "1"
        , x1 "50"
        , x2 "50"
        , y1 "350"
        , y2 "50"
        ]
        []
    , line
        [ stroke "black"
        , strokeWidth "1"
        , x1 "50"
        , x2 "350"
        , y1 "350"
        , y2 "350"
        ]
        []
    ]
