module Coincheck

using HTTP
using JSON
using WebSocketClient
import WebSocketClient: on_text
import Requests: URI

struct Client
    endpoint:: String
    websocket_endpoint:: String
end

# https://coincheck.com/ja/documents/exchange/api#about
# https://coincheck.com/ja/documents/exchange/api#websocket-overview
default_client = Client("https://coincheck.com", "wss://ws-api.coincheck.com")

function get(client :: Client, path, args)
    query = join(map(arg -> "$(arg[1])=$(arg[2])", collect(args)), "&")

    HTTP.get("$(client.endpoint)/$path?$query")
end

export call_public_api
function call_public_api(path, args = Dict())
    call_public_api(default_client, path, args)
end
function call_public_api(client :: Client, path, args = Dict())
    JSON.parse(get(client, path, args).body)
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
