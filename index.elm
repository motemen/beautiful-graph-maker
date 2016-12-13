import Html exposing (Html)
import Svg exposing (svg, defs, text_, g, line, marker, text)
import Svg.Attributes exposing (..)
import Svg.Events exposing (onClick)

main =
  Html.beginnerProgram { model = model, view = view, update = update }

type alias Model =
  { yLabelUpper : String
  , yLabelLower : String
  , lineRising : Bool
  }

model : Model
model = Model "😊" "🙁" True

type Msg
  = SetYLabelUpper String
  | SetYLabelLower String
  | ToggleTrend

update : Msg -> Model -> Model
update msg model =
  case msg of
    ToggleTrend -> { model | lineRising = not model.lineRising }
    _ -> model

view : Model -> Html Msg
view model =
  svg [ id "canvas", viewBox "-50 0 450 450" ]
    [ defs []
      [ marker [ id "arrow-head", orient "auto", refX "0", refY "5", viewBox "0 0 10 10" ]
        [ Svg.path [ d "M 0 0 L 10 5 L 0 10 z" ] [] ] ]
    , text_ [
        dominantBaseline "middle",
        dx "-50",
        style "font-size: 50px",
        textAnchor "middle",
        textLength "100",
        x "50",
        y "100" ]
      [ text model.yLabelUpper ]
    , text_ [
        dominantBaseline "middle",
        dx "-50",
        style "font-size: 50px",
        textAnchor "middle",
        textLength "100",
        x "50",
        y "300" ]
      [ text model.yLabelLower ]
    , g [ style "font-family: 'Helvetica Neue', sans-serif; font-size: 24px" ] [
        text_ [ dx "0", dy "40", textAnchor "middle", x "100", y "350" ]
          [ text "Before" ]
      , text_ [ dx "10", dy "40", textAnchor "middle", x "300", y "350" ]
          [ text "After" ]
    ]
    , line [
        id "line-up",
        markerEnd "url(#arrow-head)",
        stroke "black", strokeWidth "10",
        onClick ToggleTrend,
        x1 "100", x2 "300", y1 "300", y2 "100" ] []
    , line [
        id "line-down",
        markerEnd "url(#arrow-head)",
        stroke "black", strokeWidth "10",
        style "display: none",
        onClick ToggleTrend,
        x1 "100", x2 "300", y1 "100", y2 "300" ] []
    , line [ stroke "black", strokeWidth "1", x1 "50", x2 "50", y1 "350", y2 "50" ]
        []
    , line [ stroke "black", strokeWidth "1", x1 "50", x2 "350", y1 "350", y2 "350" ]
        []
    ]
