port module Ports.Echo exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


{-
   The main idea behind this module is to folow a different
   pattern from the smart tag translators to issue issue a command in the top
   most module.

   We want be able to issue a command fron any child module no matter how nested
   withing the arquitecture of the app, that can short circuit passing messages
   throught the child parent heirarchy and get right to the root module.


   The idea is to have a "pure" Cmd that just goes out to js land
   and comes back in as a subscription.

   client code can create a subscription like this:

   Echo.listen (Decode.decodeValue << Decode

-}


port shout : Encode.Value -> Cmd msg


port hear : (Decode.Value -> msg) -> Sub msg
