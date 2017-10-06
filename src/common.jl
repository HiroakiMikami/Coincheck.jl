struct WebsocketApiHandler{F} <: WebSocketHandler
    client:: WSClient
    on_data:: F
end
export WebsocketApiHandler

struct Client
    endpoint:: String
    websocket_endpoint:: String
    websocket_handler:: WebsocketApiHandler
end
export Client

struct Credential
    access_key:: String
    secret_key:: String
end
export Credential

module Methods
    @enum Method GET POST
    export Method
end
export Mehotds