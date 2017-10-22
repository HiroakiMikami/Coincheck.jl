module HttpUtil

using ..Coincheck
using ..Methods
using HTTP

function make_http_request(method, url; headers = Nullable(), body = Nullable())
    const _body = (method == Coincheck.Methods.GET) ? Nullable() : body
    const make_request =
        if (method == Coincheck.Methods.GET) HTTP.get
        elseif (method == Coincheck.Methods.POST) HTTP.post
        elseif (method == Coincheck.Methods.DELETE) HTTP.delete
        else nothing
        end
    if isnull(headers) && isnull(body)
        make_request(url)
    elseif isnull(headers)
        make_request(url, body = body)
    elseif isnull(body)
        make_request(url, headers = headers)
    else
        make_request(url, headers = headers, body = body)
    end
end
export make_http_request

function convert_to_url(endpoint, path, args = Nullable())
    _endpoint = isdirpath(endpoint) ? dirname(endpoint) : endpoint
    _path = isdirpath(path) ? dirname(path) : path
    _path = isabspath(_path) ? _path[2:_path.len] : _path
    if isnull(args)
        return "$_endpoint/$_path"
    else
        query = join(map(arg -> "$(arg[1])=$(arg[2])", collect(args)), "&")
        return "$_endpoint/$_path?$query"
    end
end
export convert_to_url

end
