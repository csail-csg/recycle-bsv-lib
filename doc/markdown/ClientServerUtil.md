# ClientServerUtil


This package contains functions to modify the request and responses of a
Client or a Server interface. For each type of interface, there are three
types of functions: one transforms reqeusts, one transforms responses, and
one transforms both. In addition there are typeclasses to simplify the
naming of the Client and Server versions of each function by giving them
the same name.

Client functions:
  newClient transformClientReq(reqF, client)
  newClient transformClientResp(respF, client)
  newClient transformClientReqResp(reqF, respF, client)
Server functions:
  newServer transformServerReq(reqF, server)
  newServer transformServerResp(respF, server)
  newServer transformServerReqResp(reqF, respF, server)
Unified typeclass functions:
  newClientOrServer transformReq(reqF, clientOrServer)
  newClientOrServer transformResp(respF, clientOrServer)
  newClientOrServer transformReqResp(reqF, respF, clientOrServer)


### [Client](../../src/bsv/ClientServerUtil.bsv#L54)
```bluespec
interface Client;
                interface Get request;
                    method ActionValue#(newReqT) get;
                        let x <- client.request.get;
                        return reqF(x);
                    endmethod
                endinterface
                
```

### [Server](../../src/bsv/ClientServerUtil.bsv#L72)
```bluespec
interface Server;
                interface Put request;
                    method Action put(reqT x);
                        server.request.put(reqF(x));
                    endmethod
                endinterface
                
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

