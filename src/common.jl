struct HttpClient
    endpoint:: String
end
export HttpClient

# https://coincheck.com/ja/documents/exchange/api#about
const default_http_client = HttpClient("https://coincheck.com")

struct WebSocketClient <: WebSocketHandler
    endpoint:: String
    client:: WSClient
    callbacks:: Dict{UInt64, Function}

    # https://coincheck.com/ja/documents/exchange/api#websocket-overview
    WebSocketClient() = new("wss://ws-api.coincheck.com", WSClient(), Dict())
end
export WebSocketClient

struct Credential
    access_key:: String
    secret_key:: String
end
export Credential

module Methods
    @enum Method GET POST
    export Method
end
export Methods
