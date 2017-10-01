module Coincheck

using HTTP
using JSON

struct Client
    endpoint:: String
end

# https://coincheck.com/ja/documents/exchange/api#about
default_client = Client("https://coincheck.com")

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

end
