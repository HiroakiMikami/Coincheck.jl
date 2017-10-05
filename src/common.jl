struct Client
    endpoint:: String
    websocket_endpoint:: String
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
