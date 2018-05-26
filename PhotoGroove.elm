module PhotoGroove exposing (..)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Random

type alias Photo = { url : String }

type alias Model =
  { chosenSize : ThumbnailSize
  , photos : List Photo
  , selectedUrl : String
  }

type Msg
  = SelectByUrl String
  | SelectByIndex Int
  | SupriseMe
  | SetSize ThumbnailSize

type ThumbnailSize
  = Small
  | Medium
  | Large

urlPrefix : String
urlPrefix =
  "http://elm-in-action.com/"

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SelectByUrl url ->
      ({ model | selectedUrl = url }, Cmd.none)
    SelectByIndex index ->
      ({ model | selectedUrl = getPhotoUrl index }, Cmd.none)
    SupriseMe ->
      (model, Random.generate SelectByIndex randomPhotoPicker)
    SetSize size ->
      ({ model | chosenSize = size }, Cmd.none)

view : Model -> Html Msg
view model =
  div [ class "content" ]
      [ h1 [] [ text "Photo Groove" ]
      , button
          [ onClick SupriseMe ]
          [ text "Suprise Me" ]
      , h3 [] [ text "Thumbnail Size:"]
      , div
          [ id "choose-size" ]
          (List.map (viewSizeChooser model.chosenSize) [ Small, Medium, Large ])
      , div
          [ id "thumbnails", class (sizeToString model.chosenSize) ]
          (List.map (viewThumbnail model.selectedUrl) model.photos)
      , img
          [ class "large"
          , src (urlPrefix ++ "large/" ++ model.selectedUrl)
          ]
          []
      ]

viewThumbnail : String -> Photo -> Html Msg
viewThumbnail selectedUrl thumbnail =
  img
    [
      src (urlPrefix ++ thumbnail.url)
    , classList [ ("selected", thumbnail.url == selectedUrl) ]
    , onClick (SelectByUrl thumbnail.url)
    ]
    []

viewSizeChooser : ThumbnailSize -> ThumbnailSize -> Html Msg
viewSizeChooser selectedSize size =
  label []
        [ input [ type_ "radio", name "size", onClick (SetSize size), checked (selectedSize == size)] []
        , text (sizeToString size)
        ]

sizeToString : ThumbnailSize -> String
sizeToString size =
  case size of
    Small -> "small"
    Medium -> "med"
    Large -> "large"

initialModel : Model
initialModel =
  { photos =
      [ { url = "1.jpeg" }
      , { url = "2.jpeg" }
      , { url = "3.jpeg" }
      ]
  , selectedUrl = "1.jpeg"
  , chosenSize = Medium
  }

photoArray : Array Photo
photoArray =
  Array.fromList initialModel.photos

getPhotoUrl : Int -> String
getPhotoUrl index =
  case Array.get index photoArray of
    Just photo ->
      photo.url
    Nothing ->
      ""

randomPhotoPicker : Random.Generator Int
randomPhotoPicker =
  Random.int 0 (Array.length photoArray - 1)

main : Program Never Model Msg
main =
  Html.program
    { init = (initialModel, Cmd.none)
    , view = view
    , update = update
    , subscriptions = (\model -> Sub.none)
    }
