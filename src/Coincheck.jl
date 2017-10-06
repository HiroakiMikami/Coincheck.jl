module Coincheck

using HTTP
using JSON
using Nettle
using WebSocketClient
import WebSocketClient: on_text
import Requests: URI

include("common.jl")

# https://coincheck.com/ja/documents/exchange/api#about
# https://coincheck.com/ja/documents/exchange/api#websocket-overview
const default_client = Client(
    "https://coincheck.com", "wss://ws-api.coincheck.com",
    WebsocketApiHandler(WSClient(), Channel{Array{Any, 1}}(32))
)

include("HttpUtil.jl")

export call_public_api
function call_public_api(path, args = Nullable())
    call_public_api(default_client, path, args)
end
function call_public_api(client :: Client, path, args = Nullable())
    response = HttpUtil.make_http_request(Methods.GET, HttpUtil.convert_to_url(client, path, args))
    JSON.parse(response.body)
end

export call_private_api
function call_private_api(credential, method, path, args = Nullable())
    call_private_api(default_client, credential, method, path, args)
end
function call_private_api(client :: Client, credential, method, path, args = Nullable())
    # nonce
    nonce = string(UInt64(Dates.time() * 1e6))
    # url
    url = HttpUtil.convert_to_url(client, path, (method == Methods.GET) ? args : Nullable())
    # body
    body = (method == Methods.GET) ? "" : JSON.json(args)

    message = nonce * url * body
    signature = Nettle.hexdigest("sha256", credential.secret_key, message)

    headers = Dict{String, String}("ACCESS-KEY" => credential.access_key, "ACCESS-NONCE" => nonce, "ACCESS-SIGNATURE" => signature)
    if body == ""
        return HttpUtil.make_http_request(method, url, headers = headers)
    else
        return HttpUtil.make_http_request(method, url, headers = headers, body = body)
    end
end

on_text(handler:: WebsocketApiHandler, s:: String) = begin
    try
        put!(handler.data, JSON.parse(s))
    catch ex
        # TODO error-handling
        println(ex)
    end
end
function subscribe(channels)
    subscribe(default_client, channels)
end
function subscribe(client:: Client, channels)
    # Connect to Coincheck server
    wsconnect(client.websocket_handler.client, URI(client.websocket_endpoint), client.websocket_handler)

    # Make requests
    for channel = collect(channels)
        json = JSON.json(Dict("type" => "subscribe", "channel" => channel))
        send_text(client.websocket_handler.client, json)
    end
end

end
