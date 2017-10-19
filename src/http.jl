struct HttpClient
    endpoint:: String
end
export HttpClient

# https://coincheck.com/ja/documents/exchange/api#about
const default_http_client = HttpClient("https://coincheck.com")

function call_http_api(path; method = Methods.GET, credential = Nullable(), args = Dict())
    call_http_api(defaut_http_client, path, method = method, credential = credential, args = args)
end
function call_http_api(client:: HttpClient, path; method = Methods.GET, credential = Nullable(), args = Nullable())
    # URL
    url = HttpUtil.convert_to_url(client.endpoint, path, (method == Methods.GET) ? args : Nullable())
    # Body
    body = (method == Methods.GET) ? Nullable() : JSON.json(args)

    headers = Nullable()

    if !isnull(credential)
        # nonce
        nonce = string(UInt64(Dates.time() * 1e6))

        message = nonce * url * (isnull(body) ? "" : body)
        signature = Nettle.hexdigest("sha256", credential.secret_key, message)

        headers = Dict{String, String}("ACCESS-KEY" => credential.access_key, "ACCESS-NONCE" => nonce, "ACCESS-SIGNATURE" => signature)
    end

    response = HttpUtil.make_http_request(method, url, headers = headers, body = body)
    return JSON.parse(response.body)
end
export call_http_api
