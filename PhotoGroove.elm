module PhotoGroove exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

urlPrefix =
  "http://elm-in-action.com/"

update msg model =
  if msg.operation == "PHOTO_SELECTED" then
    { model | selectedUrl = msg.data }
  else
    model

view model =
  div [ class "content" ]
      [ h1 [] [ text "Photo Groove" ]
      , div [ id "thumbnails" ]
            (List.map (viewThumbnail model.selectedUrl) model.photos)
      , img [ class "large"
            , src (urlPrefix ++ "large/" ++ model.selectedUrl)
            ]
            []
      ]

viewThumbnail selectedUrl thumbnail =
  img
    [
      src (urlPrefix ++ thumbnail.url)
    , classList [ ("selected", thumbnail.url == selectedUrl) ]
    , onClick { operation = "PHOTO_SELECTED", data = thumbnail.url }
    ]
    []

initialModel =
  { photos =
      [ { url = "1.jpeg" }
      , { url = "2.jpeg" }
      , { url = "3.jpeg" }
      ]
  , selectedUrl = "1.jpeg"
  }

main =
  Html.beginnerProgram
    { model = initialModel
    , view = view
    , update = update
    }
