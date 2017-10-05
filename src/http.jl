function make_http_request(method, url; headers = Nullable(), body = Nullable())
    if method == Coincheck.Methods.GET
        if isnull(headers) && isnull(body)
            HTTP.get(url)
        else
            return HTTP.get(url, headers = headers)
        end
    elseif method == Coincheck.Methods.POST
        if isnull(headers) && isnull(body)
        elseif isnull(headers)
            return HTTP.post(url, headers = headers)
        elseif isnull(body)
            return HTTP.post(url, body = body)
        else
            return HTTP.post(url, headers = headers, body = body)
        end
    end
end
