module HttpUtil

using ..Coincheck
using ..Methods
using HTTP

function make_http_request(method, url; headers = Nullable(), body = Nullable())
    if method == Coincheck.Methods.GET
        if isnull(headers) && isnull(body)
            return HTTP.get(url)
        else
            return HTTP.get(url, headers = headers)
        end
    elseif method == Coincheck.Methods.POST
        if isnull(headers) && isnull(body)
            return HTTP.post(url)
        elseif isnull(headers)
            return HTTP.post(url, headers = headers)
        elseif isnull(body)
            return HTTP.post(url, body = body)
        else
            return HTTP.post(url, headers = headers, body = body)
        end
    end
end

function convert_to_url(client:: Coincheck.HttpClient, path, args = Nullable())
    if isnull(args)
        return "$(client.endpoint)/$path"
    else
        query = join(map(arg -> "$(arg[1])=$(arg[2])", collect(args)), "&")
        return "$(client.endpoint)/$path?$query"
    end
end

end
