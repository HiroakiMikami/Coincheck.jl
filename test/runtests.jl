using Coincheck
using Base.Test

using HTTP

@testset "HttpUtil" begin
    importall Coincheck.HttpUtil
    @test convert_to_url("http://localhost", "foo") == "http://localhost/foo"
    @test convert_to_url("http://localhost", "foo", Dict("one" => 1, "two" => 2)) == "http://localhost/foo?two=2&one=1"
    @test convert_to_url("http://localhost/", "foo") == "http://localhost/foo"
    @test convert_to_url("http://localhost", "/foo") == "http://localhost/foo"
    @test convert_to_url("http://localhost", "foo/") == "http://localhost/foo"
end

@testset "call_http_api Tests" begin
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
        put!(server.in, 9)
    end

end
