module PhotoGroove exposing (..)

import Array exposing (Array)
import Html exposing (..)
import Html.Attributes exposing (id, checked, class, classList, src, name, type_, title)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (string, int, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Random

type alias Photo =
  { url : String
  , size: Int
  , title: String
  }

type alias Model =
  { chosenSize : ThumbnailSize
  , photos : List Photo
  , selectedUrl : Maybe String
  , loadingError : Maybe String
  }

type Msg
  = SelectByUrl String
  | SelectByIndex Int
  | SupriseMe
  | SetSize ThumbnailSize
  | LoadPhotos (Result Http.Error (List Photo))

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
      ({ model | selectedUrl = Just url }, Cmd.none)
    SelectByIndex index ->
      let
        newSelectedUrl : Maybe String
        newSelectedUrl =
          model.photos
          |> Array.fromList
          |> Array.get index
          |> Maybe.map .url
      in
        ({ model | selectedUrl = newSelectedUrl }, Cmd.none)
    SupriseMe ->
      let
        randomPhotoPicker =
          Random.int 0 (List.length model.photos - 1)
      in
        (model, Random.generate SelectByIndex randomPhotoPicker)
    SetSize size ->
      ({ model | chosenSize = size }, Cmd.none)
    LoadPhotos (Ok photos) ->
      ({ model | photos = photos, selectedUrl = Maybe.map .url (List.head photos) }, Cmd.none)
    LoadPhotos (Err _) ->
      ({ model | loadingError = Just "Error! (Try turning it off and on again?)" }, Cmd.none)

viewOrError : Model -> Html Msg
viewOrError model =
  case model.loadingError of
    Nothing ->
      view model
    Just errorMessage ->
      div [ class "error-message" ]
          [ h1 [] [ text "Photo Groove" ]
          , p [] [ text errorMessage ]
          ]

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
      , viewLarge model.selectedUrl
      ]

viewLarge : Maybe String -> Html Msg
viewLarge maybeUrl =
  case maybeUrl of
    Nothing ->
      text ""
    Just url ->
      img [ class "large", src (urlPrefix ++ "large/" ++ url) ] []

viewThumbnail : Maybe String -> Photo -> Html Msg
viewThumbnail selectedUrl thumbnail =
  img
    [
      src (urlPrefix ++ thumbnail.url)
    , title (thumbnail.title ++ " [" ++ toString thumbnail.size ++ " KB]")
    , classList [ ("selected", Just thumbnail.url == selectedUrl) ]
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

photoDecoder : Decoder Photo
photoDecoder =
  decode Photo
  |> required "url" string
  |> required "size" int
  |> optional "title" string "(untitled)"

initialCommand : Cmd Msg
initialCommand =
  list photoDecoder
  |> Http.get "http://elm-in-action.com/photos/list.json"
  |> Http.send LoadPhotos

initialModel : Model
initialModel =
  { photos = []
  , selectedUrl = Nothing
  , loadingError = Nothing
  , chosenSize = Medium
  }

main : Program Never Model Msg
main =
  Html.program
    { init = (initialModel, initialCommand)
    , view = viewOrError
    , update = update
    , subscriptions = (\_ -> Sub.none)
    }
