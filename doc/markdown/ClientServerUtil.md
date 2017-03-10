## TransformReqHelper
```bluespec
instance TransformReqHelper#(Client#(reqT, respT), reqT, newReqT, Client#(newReqT, respT));
    function Client#(newReqT, respT) transformReq(function newReqT f(reqT x),
                                                  Client#(reqT, respT) ifc);
        return transformClientReq(f, ifc);
    endfunction
endinstance


```

## TransformReqHelper
```bluespec
instance TransformReqHelper#(Server#(newReqT, respT), reqT, newReqT, Server#(reqT, respT));
    function Server#(reqT, respT) transformReq(function newReqT f(reqT x),
                                               Server#(newReqT, respT) ifc);
        return transformServerReq(f, ifc);
    endfunction
endinstance


```

## TransformRespHelper
```bluespec
instance TransformRespHelper#(Client#(reqT, newRespT), respT, newRespT, Client#(reqT, respT));
    function Client#(reqT, respT) transformResp(function newRespT f(respT x),
                                                Client#(reqT, newRespT) ifc);
        return transformClientResp(f, ifc);
    endfunction
endinstance


```

## TransformRespHelper
```bluespec
instance TransformRespHelper#(Server#(reqT, respT), respT, newRespT, Server#(reqT, newRespT));
    function Server#(reqT, newRespT) transformResp(function newRespT f(respT x),
                                                   Server#(reqT, respT) ifc);
        return transformServerResp(f, ifc);
    endfunction
endinstance


```

## TransformReqRespHelper
```bluespec
instance TransformReqRespHelper#(Client#(reqT, newRespT), reqT, respT, newReqT, newRespT, Client#(newReqT, respT));
    function Client#(newReqT, respT) transformReqResp(function newReqT reqF(reqT x),
                                                      function newRespT respF(respT x),
                                                      Client#(reqT, newRespT) ifc);
        return transformClientReqResp(reqF, respF, ifc);
    endfunction
endinstance


```

## TransformReqRespHelper
```bluespec
instance TransformReqRespHelper#(Server#(newReqT, respT), reqT, respT, newReqT, newRespT, Server#(reqT, newRespT));
    function Server#(reqT, newRespT) transformReqResp(function newReqT reqF(reqT x),
                                                      function newRespT respF(respT x),
                                                      Server#(newReqT, respT) ifc);
        return transformServerReqResp(reqF, respF, ifc);
    endfunction
endinstance


```
