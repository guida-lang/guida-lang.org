port module Session exposing
    ( Msg(..)
    , Session
    , init
    , isMobileNavigationOpen
    , navKey
    , theme
    , update
    , year
    )

import Browser.Navigation as Nav
import Components.ThemeToggle as ThemeToggle



-- SESSION


type alias Session =
    { year : Int
    , theme : ThemeToggle.Theme
    , isMobileNavigationOpen : Bool
    , navKey : Nav.Key
    }


init : Int -> ThemeToggle.Theme -> Nav.Key -> Session
init year_ theme_ navKey_ =
    { year = year_
    , theme = theme_
    , isMobileNavigationOpen = False
    , navKey = navKey_
    }


year : Session -> Int
year =
    .year


theme : Session -> ThemeToggle.Theme
theme =
    .theme


navKey : Session -> Nav.Key
navKey =
    .navKey


isMobileNavigationOpen : Session -> Bool
isMobileNavigationOpen =
    .isMobileNavigationOpen



-- UPDATE


type Msg
    = SetTheme ThemeToggle.Theme
    | ToggleMobileNavigation
    | OnResize { breakpoint : Int, width : Int }


update : Msg -> Session -> ( Session, Cmd msg )
update msg session =
    case msg of
        SetTheme value ->
            ( { session | theme = value }, setTheme (ThemeToggle.themeToString value) )

        ToggleMobileNavigation ->
            ( { session | isMobileNavigationOpen = not session.isMobileNavigationOpen }, Cmd.none )

        OnResize { breakpoint, width } ->
            if width >= breakpoint then
                ( { session | isMobileNavigationOpen = False }, Cmd.none )

            else
                ( session, Cmd.none )


port setTheme : String -> Cmd msg
