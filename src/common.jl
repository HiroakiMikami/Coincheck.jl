struct Credential
    access_key:: String
    secret_key:: String
end
export Credential

module Methods
    @enum Method GET POST DELETE
    export Method
end
export Methods
