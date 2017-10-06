struct HttpClient
    endpoint:: String
end
export HttpClient

# https://coincheck.com/ja/documents/exchange/api#about
const default_http_client = HttpClient("https://coincheck.com")

struct WebSocketClient{F} <: WebSocketHandler
    endpoint:: String
    client:: WSClient
    on_data:: F
end
export WebSocketClient

# https://coincheck.com/ja/documents/exchange/api#websocket-overview
const default_websocket_client = WebSocketClient("wss://ws-api.coincheck.com", WSClient(), x -> println(x))

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