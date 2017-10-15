struct WebSocketClient <: WebSocketHandler
    endpoint:: String
    client:: WSClient
    callbacks:: Dict{UInt64, Function}

    # https://coincheck.com/ja/documents/exchange/api#websocket-overview
    WebSocketClient() = new("wss://ws-api.coincheck.com", WSClient(), Dict())
end
export WebSocketClient

on_text(handler:: WebSocketClient, s:: String) = begin
    try
        for x in handler.callbacks
            x[2](JSON.parse(s))
        end
    catch ex
        # TODO error-handling
        println(ex)
    end
end
function connect(client:: WebSocketClient)
    # Connect to Coincheck server
    wsconnect(client.client, URI(client.endpoint), client)
end
function consume!(callback:: Function, client:: WebSocketClient)
    while true
        id = rand(0:UInt64(1) << 63)
        if !haskey(client.callbacks, id)
            client.callbacks[id] = callback
            return id
        end
    end
end
function delete!(id:: UInt64, client:: WebSocketClient)
    if haskey(client.callbacks, id)
        Base.delete!(client.callbacks, id)
    end
end
function subscribe(client:: WebSocketClient, channels)
    # Make requests
    for channel = collect(channels)
        json = JSON.json(Dict("type" => "subscribe", "channel" => channel))
        send_text(client.client, json)
    end
end
