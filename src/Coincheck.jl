module Coincheck

using HTTP

# https://coincheck.com/ja/documents/exchange/api#about
protocol = "https"
host = "coincheck.com"

function get(path, args)
    query = join(map(arg -> "$(arg[1])=$(arg[2])", collect(args)), "&")

    HTTP.get("$protocol://$host/$path?$query")
end

export call_public_api
function call_public_api(path, args = Dict())
    get(path, args)
end

end
