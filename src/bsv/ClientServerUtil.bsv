
// Copyright (c) 2016 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

package ClientServerUtil;

import ClientServer::*;
import GetPut::*;

typeclass ClientServerUtilHelper#(type clientOrServer, type reqT, type respT) dependencies (clientOrServer determines (reqT, respT));
    function clientOrServer transformReqResp(   function reqT reqF(reqT x),
                                                function respT respFunc(respT x),
                                                clientOrServer ifc );
    function clientOrServer transformReq(function reqT f(reqT x), clientOrServer ifc);
        return transformReqResp( f, id, ifc );
    endfunction
    function clientOrServer transformResp(function respT f(respT x), clientOrServer ifc);
        return transformReqResp( id, f, ifc );
    endfunction
endtypeclass

instance ClientServerUtilHelper#(Client#(reqT, respT), reqT, respT);
    function Client#(reqT, respT) transformReqResp( function reqT reqF(reqT x),
                                                    function respT respF(respT x),
                                                    Client#(reqT, respT) client );
        return (interface Client;
                    interface Get request;
                        method ActionValue#(reqT) get;
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
endinstance

instance ClientServerUtilHelper#(Server#(reqT, respT), reqT, respT);
    function Server#(reqT, respT) transformReqResp( function reqT reqF(reqT x),
                                                    function respT respF(respT x),
                                                    Server#(reqT, respT) server );
        return (interface Server;
                    interface Put request;
                        method Action put(reqT x);
                            server.request.put(reqF(x));
                        endmethod
                    endinterface
                    interface Get response;
                        method ActionValue#(respT) get;
                            let x <- server.response.get;
                            return respF(x);
                        endmethod
                    endinterface
                endinterface);
    endfunction
endinstance

endpackage
