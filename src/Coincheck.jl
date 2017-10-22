module Coincheck

using JSON
using Nettle
using WebSocketClient
import WebSocketClient: on_text
import Requests: URI

include("common.jl")
include("HttpUtil.jl")

include("http.jl")
include("websocket.jl")

end
