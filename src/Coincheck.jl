module Coincheck

using JSON
using Nettle
using WebSocketClient
import WebSocketClient: on_text
import Requests: URI

include("common.jl")

include("HttpUtil.jl")

function call_http_api(path; method = Methods.GET, credential = Nullable(), args = Dict())
    call_http_api(defaut_http_client, path, method = method, credential = credential, args = args)
end
function call_http_api(client:: HttpClient, path; method = Methods.GET, credential = Nullable(), args = Dict())
    # URL
    url = HttpUtil.convert_to_url(client, path, (method == Methods.GET) ? args : Nullable())
    # Body
    body = (method == Methods.GET) ? Nullable() : JSON.json(args)

    headers = Nullable()

    if !isnull(credential)
        # nonce
        nonce = string(UInt64(Dates.time() * 1e6))

        message = nonce * url * body
        signature = Nettle.hexdigest("sha256", credential.secret_key, message)

        headers = Dict{String, String}("ACCESS-KEY" => credential.access_key, "ACCESS-NONCE" => nonce, "ACCESS-SIGNATURE" => signature)
    end

    response = HttpUtil.make_http_request(method, url, headers = headers, body = body)
    return JSON.parse(response.body)
end
export call_http_api

on_text(handler:: WebSocketClient, s:: String) = begin
    println("foo")
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

end
