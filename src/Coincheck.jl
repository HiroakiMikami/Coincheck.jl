module Coincheck

using JSON
using Nettle
using WebSocketClient
import WebSocketClient: on_text
import Requests: URI

include("common.jl")

include("HttpUtil.jl")

export call_public_api
function call_public_api(path, args = Nullable())
    call_public_api(default_http_client, path, args)
end
function call_public_api(client :: HttpClient, path, args = Nullable())
    response = HttpUtil.make_http_request(Methods.GET, HttpUtil.convert_to_url(client, path, args))
    JSON.parse(response.body)
end

export call_private_api
function call_private_api(credential, method, path, args = Nullable())
    call_private_api(default_http_client, credential, method, path, args)
end
function call_private_api(client :: HttpClient, credential, method, path, args = Nullable())
    # nonce
    nonce = string(UInt64(Dates.time() * 1e6))
    # url
    url = HttpUtil.convert_to_url(client, path, (method == Methods.GET) ? args : Nullable())
    # body
    body = (method == Methods.GET) ? "" : JSON.json(args)

    message = nonce * url * body
    signature = Nettle.hexdigest("sha256", credential.secret_key, message)

    headers = Dict{String, String}("ACCESS-KEY" => credential.access_key, "ACCESS-NONCE" => nonce, "ACCESS-SIGNATURE" => signature)
    response = (body == "") ? HttpUtil.make_http_request(method, url, headers = headers) : HttpUtil.make_http_request(method, url, headers = headers, body = body)
    return JSON.parse(response.body)
end

on_text(handler:: WebSocketClient, s:: String) = begin
    try
        handler.on_data(JSON.parse(s))
    catch ex
        # TODO error-handling
        println(ex)
    end
end
function subscribe(channels)
    subscribe(default_websocket_client, channels)
end
function subscribe(client:: WebSocketClient, channels)
    # Connect to Coincheck server
    wsconnect(client.client, URI(client.endpoint), client)

    # Make requests
    for channel = collect(channels)
        json = JSON.json(Dict("type" => "subscribe", "channel" => channel))
        send_text(client.client, json)
    end
end

end
