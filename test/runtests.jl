using Coincheck
using Base.Test

using HTTP

@testset "call_public_api Tests" begin
    server = HTTP.Server((req, rep) -> begin
        req.uri == HTTP.URI("/success") && return HTTP.Response("""{"success": true}""")
        req.uri == HTTP.URI("/failure") && return HTTP.Response("""failure""")
        HTTP.Response("")
    end)
    client = Coincheck.HttpClient("http://127.0.0.1:8081")

    try
        @spawn HTTP.serve(server, HTTP.IPv4(127,0,0,1), 8081)

        @test Coincheck.call_http_api(client, "success") == Dict("success" => true)
        @test_throws ErrorException Coincheck.call_http_api(client, "failure")
    finally
        put!(server.in, HTTP.KILL)
    end

end
