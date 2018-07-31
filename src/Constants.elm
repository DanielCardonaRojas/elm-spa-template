module Constants exposing (..)

import Data.Types exposing (..)


-- Strings


baseUrl =
    "%API_URL%"


apiVersion =
    "%API_VERSION%"


socketioUrl =
    "%SOCKETIO_URL%"


googleApiKey =
    "%GOOGLE_API_KEY%"


apiUrl =
    baseUrl ++ "/" ++ apiVersion


string =
    { login = "login"
    , signup = "signup"
    }



-- Numbers


tokenRefreshRate =
    10



-- Refresh token every n minutes
-- Endpoints


apiEndpoint =
    { lightshows = apiUrl ++ "/lightshows"
    , lightshowEvents = apiUrl ++ "/lightshowevents"
    , eventConfig = apiUrl ++ "/playback_configurations"
    , tokenRefresh = apiUrl ++ "/auth/token-refresh"
    , token = apiUrl ++ "/auth/token"
    , gifUpload = baseUrl ++ "/upload"
    }



-- Routes


getCRUDRoutes : URL -> { list : URL, new : URL, edit : URL }
getCRUDRoutes componentRoute =
    { list = componentRoute
    , new = componentRoute ++ "/new"
    , edit = componentRoute ++ "/edit"
    }


navigationRoute =
    { login = string.login
    , signup = string.signup
    }
