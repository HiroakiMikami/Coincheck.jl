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
const default_client = Client("https://coincheck.com", "wss://ws-api.coincheck.com")

include("http.jl")

export call_public_api
function call_public_api(path, args = Nullable())
    call_public_api(default_client, path, args)
end
function call_public_api(client :: Client, path, args = Nullable())
    response = make_http_request(Methods.GET, convert_to_url(client, path, args))
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
    url = (method == Methods.GET) ? convert_to_url(client, path, args) : convert_to_url(client, path)
    # body
    body = (method == Methods.GET) ? "" : JSON.json(args)

    message = nonce * url * body
    signature = Nettle.hexdigest("sha256", credential.secret_key, message)

    headers = Dict{String, String}("ACCESS-KEY" => credential.access_key, "ACCESS-NONCE" => nonce, "ACCESS-SIGNATURE" => signature)
    if body == ""
        return make_http_request(method, url, headers = headers)
    else
        return make_http_request(method, url, headers = headers, body = body)
    end
end

export ChannelType
@enum ChannelType TRADES ORDERBOOK

export Channel
struct Channel
    channel_type:: ChannelType
    pair:: String
end

function stringify(channel :: Channel)
    channel.channel_type == TRADES && return "$(channel.pair)-trades"
    channel.channel_type == ORDERBOOK && return "$(channel.pair)-orderbook"
end

struct CoincheckApiHandler <: WebSocketHandler
    client:: WSClient
    data:: Base.Channel{Tuple{Channel, Array{Any, 1}}}
end
on_text(handler ::CoincheckApiHandler, s:: String) = begin
    try
        data = JSON.parse(s)

        if size(data)[1] > 0
            if isa(data[1], Number)
                put!(handler.data, (Channel(TRADES, data[2]), data))
            else
                put!(handler.data, (Channel(ORDERBOOK, data[1]), data))
            end
        end
    catch ex
        # TODO error-handling
        println(ex)
    end
end

export subscribe
function subscribe(channels)
    subscribe(default_client, channels)
end
function subscribe(client :: Client, channels)
    handler = CoincheckApiHandler(WSClient(), Base.Channel{Tuple{Channel, Array{Any, 1}}}(32))

    # Connect to Coincheck server
    wsconnect(handler.client, URI(client.websocket_endpoint), handler)

    # Make requests
    for channel = collect(channels)
        json = JSON.json(Dict("type" => "subscribe", "channel" => stringify(channel)))
        send_text(handler.client, json)
    end

    return handler
end

end
