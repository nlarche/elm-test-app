module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import String


-- model


type alias Model =
    { players : List Player
    , name : String
    , playerId : Maybe Int
    , plays : List Play
    }


type alias Player =
    { id : Int
    , name : String
    , points : Int
    }


type alias Play =
    { id : Int
    , playerId : Int
    , name : String
    , points : Int
    }


initModel : Model
initModel =
    { players = []
    , name = ""
    , playerId = Nothing
    , plays = []
    }



-- update


type Msg
    = Edit Player
    | Score Player Int
    | Input String
    | Save
    | Cancel
    | DeletePlay Play


update : Msg -> Model -> Model
update msg model =
    case msg of
        Input name ->
            Debug.log "Input Updated Model"
                { model | name = name }

        Save ->
            if (String.isEmpty model.name) then
                model
            else
                save model

        Cancel ->
            Debug.log "Save new Player"
                { model
                    | name = ""
                    , playerId = Nothing
                }

        Score player points ->
            score model player points

        Edit player ->
            { model | name = player.name, playerId = Just player.id }

        DeletePlay play ->
            deletePlay model play      


deletePlay : Model -> Play -> Model
deletePlay model play =
    let
        newPlays =
            List.filter (\p -> p.id /= play.id) model.plays

        newPlayers =
            List.map
                (\player ->
                    if (player.id == play.playerId) then
                        { player | points = player.points - 1 * play.points }
                    else
                        player
                )
                model.players
    in
        { model | plays = newPlays, players = newPlayers }


score : Model -> Player -> Int -> Model
score model scorer points =
    let
        newPlayers =
            List.map
                (\player ->
                    if (player.id == scorer.id) then
                        { player | points = scorer.points + points }
                    else
                        player
                )
                model.players

        play =
            Play (List.length model.plays) scorer.id scorer.name points
    in
        { model | players = newPlayers, plays = play :: model.plays }


save : Model -> Model
save model =
    case model.playerId of
        Just id ->
            edit model id

        Nothing ->
            add model


edit : Model -> Int -> Model
edit model id =
    let
        newPlayers =
            List.map
                (\player ->
                    if (player.id == id) then
                        { player | name = model.name }
                    else
                        player
                )
                model.players

        newPlays =
            List.map
                (\play ->
                    if (play.playerId == id) then
                        { play | name = model.name }
                    else
                        play
                )
                model.plays
    in
        { model
            | players = newPlayers
            , plays = newPlays
            , name = ""
            , playerId = Nothing
        }


add : Model -> Model
add model =
    let
        player =
            Player (List.length model.players) model.name 0

        newPlayes =
            player :: model.players
    in
        { model
            | players = newPlayes
            , name = ""
        }



-- view


view : Model -> Html Msg
view model =
    div [ class "scoreboard" ]
        [ h1 [] [ text "Score keeper" ]
        , playerSection model
        , playerForm model
        , playSection model
        , p [] [ text (toString model) ]
        ]


playerForm : Model -> Html Msg
playerForm model =
    Html.form [ onSubmit Save ]
        [ input
            [ type' "text"
            , placeholder "Add/Edit Player..."
            , onInput Input
            , value model.name
            ]
            []
        , button [ type' "submit" ] [ text "Save" ]
        , button [ type' "button", onClick Cancel ] [ text "Cancel" ]
        ]


playerSection : Model -> Html Msg
playerSection model =
    div []
        [ listHeader "Name"
        , playerList model
        , pointTotal model
        ]


listHeader : String -> Html Msg
listHeader text' =
    header []
        [ div [] [ text text' ]
        , div [] [ text "Points" ]
        ]


playerList : Model -> Html Msg
playerList model =
    model.players
        |> List.sortBy .name
        |> List.map player
        |> ul []


player : Player -> Html Msg
player player =
    li []
        [ i
            [ class "edit"
            , onClick (Edit player)
            ]
            []
        , div []
            [ text player.name ]
        , button
            [ type' "button"
            , onClick (Score player 2)
            ]
            [ text "2pts" ]
        , button
            [ type' "button"
            , onClick (Score player 3)
            ]
            [ text "3pts" ]
        , div []
            [ text (toString player.points) ]
        ]


pointTotal : Model -> Html Msg
pointTotal model =
    let
        total =
            List.map .points model.plays
                |> List.sum
    in
        footer []
            [ div [] [ text "Total: " ]
            , div [] [ text (toString total) ]
            ]


playSection : Model -> Html Msg
playSection model =
    div []
        [ listHeader "plays"
        , playList model
        ]


playList : Model -> Html Msg
playList model =
    model.plays
        |> List.sortBy .id
        |> List.map play
        |> ul []


play : Play -> Html Msg
play play =
    li []
        [ i
            [ class "remove"
            , onClick (DeletePlay play)
            ]
            []
        , div [] [ text play.name ]
        , div [] [ text (toString play.points) ]
        ]


main : Program Never
main =
    App.beginnerProgram
        { model = initModel
        , view = view
        , update = update
        }
