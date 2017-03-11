# ClientServerUtil


This package contains functions to modify the request and responses of a
Client or a Server interface. For each type of interface, there are three
types of functions: one transforms reqeusts, one transforms responses, and
one transforms both. In addition there are typeclasses to simplify the
naming of the Client and Server versions of each function by giving them
the same name.

Client functions:
- `newClient transformClientReq(reqF, client)`
- `newClient transformClientResp(respF, client)`
- `newClient transformClientReqResp(reqF, respF, client)`
Server functions:
- `newServer transformServerReq(reqF, server)`
- `newServer transformServerResp(respF, server)`
- `newServer transformServerReqResp(reqF, respF, server)`
Unified typeclass functions:
- `newClientOrServer transformReq(reqF, clientOrServer)`
- `newClientOrServer transformResp(respF, clientOrServer)`
- `newClientOrServer transformReqResp(reqF, respF, clientOrServer)`


### [transformClientReqResp](../../src/bsv/ClientServerUtil.bsv#L51)
```bluespec
function Client#(newReqT, respT) transformClientReqResp(function newReqT reqF(reqT x),
                                                        function newRespT respF(respT x),
                                                        Client#(reqT, newRespT) client);
    return (interface Client;
                interface Get request;
                    method ActionValue#(newReqT) get;
                        let x <- client.request.get;
                        return reqF(x);
                    endmethod
                endinterface
                interface Put response;
                    method Action put(respT x);
                        client.response.put(respF(x));
                    endmethod
                endinterface
            endinterface);
endfunction


```

### [transformServerReqResp](../../src/bsv/ClientServerUtil.bsv#L69)
```bluespec
function Server#(reqT, newRespT) transformServerReqResp(function newReqT reqF(reqT x),
                                                        function newRespT respF(respT x),
                                                        Server#(newReqT, respT) server );
    return (interface Server;
                interface Put request;
                    method Action put(reqT x);
                        server.request.put(reqF(x));
                    endmethod
                endinterface
                interface Get response;
                    method ActionValue#(newRespT) get;
                        let x <- server.response.get;
                        return respF(x);
                    endmethod
                endinterface
            endinterface);
endfunction


```

### [transformClientReq](../../src/bsv/ClientServerUtil.bsv#L87)
```bluespec
function Client#(newReqT, respT) transformClientReq(function newReqT reqF(reqT x),
                                                    Client#(reqT, respT) client);
    return transformClientReqResp(reqF, id, client);
endfunction


```

### [transformClientResp](../../src/bsv/ClientServerUtil.bsv#L92)
```bluespec
function Client#(reqT, respT) transformClientResp(function newRespT respF(respT x),
                                                  Client#(reqT, newRespT) client);
    return transformClientReqResp(id, respF, client);
endfunction


```

### [transformServerReq](../../src/bsv/ClientServerUtil.bsv#L97)
```bluespec
function Server#(reqT, respT) transformServerReq(function newReqT reqF(reqT x),
                                                 Server#(newReqT, respT) client);
    return transformServerReqResp(reqF, id, client);
endfunction


```

### [transformServerResp](../../src/bsv/ClientServerUtil.bsv#L102)
```bluespec
function Server#(reqT, newRespT) transformServerResp(function newRespT respF(respT x),
                                                     Server#(reqT, respT) client);
    return transformServerReqResp(id, respF, client);
endfunction



```

### [TransformReqHelper](../../src/bsv/ClientServerUtil.bsv#L110)
```bluespec
typeclass TransformReqHelper#(type clientOrServer, type reqT, type newReqT, type newClientOrServer)
        dependencies ((clientOrServer, newClientOrServer) determines (reqT, newReqT));
    function newClientOrServer transformReq(function newReqT f(reqT x),
                                            clientOrServer ifc);
endtypeclass


```

### [TransformRespHelper](../../src/bsv/ClientServerUtil.bsv#L116)
```bluespec
typeclass TransformRespHelper#(type clientOrServer, type respT, type newRespT, type newClientOrServer)
        dependencies ((clientOrServer, newClientOrServer) determines (respT, newRespT));
    function newClientOrServer transformResp(function newRespT f(respT x),
                                             clientOrServer ifc);
endtypeclass


```

### [TransformReqRespHelper](../../src/bsv/ClientServerUtil.bsv#L122)
```bluespec
typeclass TransformReqRespHelper#(type clientOrServer, type reqT, type respT, type newReqT, type newRespT, type newClientOrServer)
        dependencies ((clientOrServer, newClientOrServer) determines (reqT, respT, newReqT, newRespT));
    function newClientOrServer transformReqResp(function newReqT reqF(reqT x),
                                                function newRespT respF(respT x),
                                                clientOrServer ifc);
endtypeclass


```

### [TransformReqHelper](../../src/bsv/ClientServerUtil.bsv#L131)
```bluespec
instance TransformReqHelper#(Client#(reqT, respT), reqT, newReqT, Client#(newReqT, respT));
    function Client#(newReqT, respT) transformReq(function newReqT f(reqT x),
                                                  Client#(reqT, respT) ifc);
        return transformClientReq(f, ifc);
    endfunction
endinstance


```

### [TransformReqHelper](../../src/bsv/ClientServerUtil.bsv#L138)
```bluespec
instance TransformReqHelper#(Server#(newReqT, respT), reqT, newReqT, Server#(reqT, respT));
    function Server#(reqT, respT) transformReq(function newReqT f(reqT x),
                                               Server#(newReqT, respT) ifc);
        return transformServerReq(f, ifc);
    endfunction
endinstance


```

### [TransformRespHelper](../../src/bsv/ClientServerUtil.bsv#L145)
```bluespec
instance TransformRespHelper#(Client#(reqT, newRespT), respT, newRespT, Client#(reqT, respT));
    function Client#(reqT, respT) transformResp(function newRespT f(respT x),
                                                Client#(reqT, newRespT) ifc);
        return transformClientResp(f, ifc);
    endfunction
endinstance


```

### [TransformRespHelper](../../src/bsv/ClientServerUtil.bsv#L152)
```bluespec
instance TransformRespHelper#(Server#(reqT, respT), respT, newRespT, Server#(reqT, newRespT));
    function Server#(reqT, newRespT) transformResp(function newRespT f(respT x),
                                                   Server#(reqT, respT) ifc);
        return transformServerResp(f, ifc);
    endfunction
endinstance


```

### [TransformReqRespHelper](../../src/bsv/ClientServerUtil.bsv#L159)
```bluespec
instance TransformReqRespHelper#(Client#(reqT, newRespT), reqT, respT, newReqT, newRespT, Client#(newReqT, respT));
    function Client#(newReqT, respT) transformReqResp(function newReqT reqF(reqT x),
                                                      function newRespT respF(respT x),
                                                      Client#(reqT, newRespT) ifc);
        return transformClientReqResp(reqF, respF, ifc);
    endfunction
endinstance


```

### [TransformReqRespHelper](../../src/bsv/ClientServerUtil.bsv#L167)
```bluespec
instance TransformReqRespHelper#(Server#(newReqT, respT), reqT, respT, newReqT, newRespT, Server#(reqT, newRespT));
    function Server#(reqT, newRespT) transformReqResp(function newReqT reqF(reqT x),
                                                      function newRespT respF(respT x),
                                                      Server#(newReqT, respT) ifc);
        return transformServerReqResp(reqF, respF, ifc);
    endfunction
endinstance


```

