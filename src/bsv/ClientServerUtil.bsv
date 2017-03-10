
// Copyright (c) 2016, 2017 Massachusetts Institute of Technology

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

/**
 * This package contains functions to modify the request and responses of a
 * Client or a Server interface. For each type of interface, there are three
 * types of functions: one transforms reqeusts, one transforms responses, and
 * one transforms both. In addition there are typeclasses to simplify the
 * naming of the Client and Server versions of each function by giving them
 * the same name.
 *
 * Client functions:
 *   newClient transformClientReq(reqF, client)
 *   newClient transformClientResp(respF, client)
 *   newClient transformClientReqResp(reqF, respF, client)
 * Server functions:
 *   newServer transformServerReq(reqF, server)
 *   newServer transformServerResp(respF, server)
 *   newServer transformServerReqResp(reqF, respF, server)
 * Unified typeclass functions:
 *   newClientOrServer transformReq(reqF, clientOrServer)
 *   newClientOrServer transformResp(respF, clientOrServer)
 *   newClientOrServer transformReqResp(reqF, respF, clientOrServer)
 */

package ClientServerUtil;

import ClientServer::*;
import GetPut::*;

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

function Client#(newReqT, respT) transformClientReq(function newReqT reqF(reqT x),
                                                    Client#(reqT, respT) client);
    return transformClientReqResp(reqF, id, client);
endfunction

function Client#(reqT, respT) transformClientResp(function newRespT respF(respT x),
                                                  Client#(reqT, newRespT) client);
    return transformClientReqResp(id, respF, client);
endfunction

function Server#(reqT, respT) transformServerReq(function newReqT reqF(reqT x),
                                                 Server#(newReqT, respT) client);
    return transformServerReqResp(reqF, id, client);
endfunction

function Server#(reqT, newRespT) transformServerResp(function newRespT respF(respT x),
                                                     Server#(reqT, respT) client);
    return transformServerReqResp(id, respF, client);
endfunction


// typeclasses

typeclass TransformReqHelper#(type clientOrServer, type reqT, type newReqT, type newClientOrServer)
        dependencies ((clientOrServer, newClientOrServer) determines (reqT, newReqT));
    function newClientOrServer transformReq(function newReqT f(reqT x),
                                            clientOrServer ifc);
endtypeclass

typeclass TransformRespHelper#(type clientOrServer, type respT, type newRespT, type newClientOrServer)
        dependencies ((clientOrServer, newClientOrServer) determines (respT, newRespT));
    function newClientOrServer transformResp(function newRespT f(respT x),
                                             clientOrServer ifc);
endtypeclass

typeclass TransformReqRespHelper#(type clientOrServer, type reqT, type respT, type newReqT, type newRespT, type newClientOrServer)
        dependencies ((clientOrServer, newClientOrServer) determines (reqT, respT, newReqT, newRespT));
    function newClientOrServer transformReqResp(function newReqT reqF(reqT x),
                                                function newRespT respF(respT x),
                                                clientOrServer ifc);
endtypeclass

// instances

instance TransformReqHelper#(Client#(reqT, respT), reqT, newReqT, Client#(newReqT, respT));
    function Client#(newReqT, respT) transformReq(function newReqT f(reqT x),
                                                  Client#(reqT, respT) ifc);
        return transformClientReq(f, ifc);
    endfunction
endinstance

instance TransformReqHelper#(Server#(newReqT, respT), reqT, newReqT, Server#(reqT, respT));
    function Server#(reqT, respT) transformReq(function newReqT f(reqT x),
                                               Server#(newReqT, respT) ifc);
        return transformServerReq(f, ifc);
    endfunction
endinstance

instance TransformRespHelper#(Client#(reqT, newRespT), respT, newRespT, Client#(reqT, respT));
    function Client#(reqT, respT) transformResp(function newRespT f(respT x),
                                                Client#(reqT, newRespT) ifc);
        return transformClientResp(f, ifc);
    endfunction
endinstance

instance TransformRespHelper#(Server#(reqT, respT), respT, newRespT, Server#(reqT, newRespT));
    function Server#(reqT, newRespT) transformResp(function newRespT f(respT x),
                                                   Server#(reqT, respT) ifc);
        return transformServerResp(f, ifc);
    endfunction
endinstance

instance TransformReqRespHelper#(Client#(reqT, newRespT), reqT, respT, newReqT, newRespT, Client#(newReqT, respT));
    function Client#(newReqT, respT) transformReqResp(function newReqT reqF(reqT x),
                                                      function newRespT respF(respT x),
                                                      Client#(reqT, newRespT) ifc);
        return transformClientReqResp(reqF, respF, ifc);
    endfunction
endinstance

instance TransformReqRespHelper#(Server#(newReqT, respT), reqT, respT, newReqT, newRespT, Server#(reqT, newRespT));
    function Server#(reqT, newRespT) transformReqResp(function newReqT reqF(reqT x),
                                                      function newRespT respF(respT x),
                                                      Server#(newReqT, respT) ifc);
        return transformServerReqResp(reqF, respF, ifc);
    endfunction
endinstance

endpackage
