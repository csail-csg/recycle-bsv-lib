
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
 * This package contains a variety of functions and modules that are useful
 * when using interfaces from the `Port` package.
 */
package PortUtil;

import ClientServer::*;
import Ehr::*;
import FIFO::*;
import FIFOF::*;
import GetPut::*;
import SpecialFIFOs::*;
import Vector::*;

import FIFOG::*;
import Port::*;

/**
 * This module splits a single `ServerPort` into a vector of them with a
 * fixed priority. Port 0 has the highest priority.
 */
module mkFixedPriorityServerPortSplitter#(function Bool getsResponse(reqT x), Integer maxPendingReqs, ServerPort#(reqT, respT) server)(Vector#(size,ServerPort#(reqT, respT))) provisos (Bits#(reqT, reqTSz));
    Ehr#(TAdd#(size,1), Maybe#(Tuple2#(UInt#(TLog#(size)),reqT))) inputRequest <- mkEhr(tagged Invalid);

    // bookkeeping for pending requests and arbiter priority
    FIFOG#(UInt#(TLog#(size))) pendingReqFIFO <- mkSizedFIFOG(maxPendingReqs);

    rule forwardRequest (inputRequest[valueOf(size)] matches tagged Valid .index_req);
        let {i, req} = index_req;
        server.request.enq(req);
        if (getsResponse(req)) begin
            pendingReqFIFO.enq(i);
        end
        inputRequest[valueOf(size)] <= tagged Invalid;
    endrule

    function ServerPort#(reqT, respT) genArbPort(Integer i);
        return (interface ServerPort;
                    interface InputPort request;
                        method Action enq(reqT req) if (!isValid(inputRequest[i]));
                            inputRequest[i] <= tagged Valid tuple2(fromInteger(i), req);
                        endmethod
                        method Bool canEnq;
                            return !isValid(inputRequest[i]);
                        endmethod
                    endinterface
                    interface OutputPort response;
                        method respT first if (pendingReqFIFO.first == fromInteger(i));
                            return server.response.first;
                        endmethod
                        method Action deq if (pendingReqFIFO.first == fromInteger(i));
                            pendingReqFIFO.deq;
                            server.response.deq;
                        endmethod
                        method Bool canDeq;
                            if (pendingReqFIFO.canDeq && server.response.canDeq) begin
                                return pendingReqFIFO.first == fromInteger(i);
                            end else begin
                                return False;
                            end
                        endmethod
                    endinterface
                endinterface);
    endfunction

    Vector#(size,ServerPort#(reqT, respT)) ifc = genWith(genArbPort);
    return ifc;
endmodule

/**
 * This is a variation on `mkFixedPriorityServerPortSplitter` that adds input
 * buffers to remove scheduling constraints between each of the output
 * servers.
 */
module mkBufferedFixedPriorityServerPortSplitter#(function Bool getsResponse(reqT x), Integer maxPendingReqs, ServerPort#(reqT, respT) server)(Vector#(size,ServerPort#(reqT, respT))) provisos (Bits#(reqT, reqTSz));
    Vector#(size, FIFOG#(reqT)) inputRequestFIFOs <- replicateM(mkBypassFIFOG);

    // bookkeeping for pending requests and arbiter priority
    FIFOG#(UInt#(TLog#(size))) pendingReqFIFO <- mkSizedFIFOG(maxPendingReqs);

    rule forwardRequest;
        Maybe#(Integer) maybeIndex = tagged Invalid;
        for (Integer i = valueOf(size)-1 ; i >= 0 ; i = i - 1) begin
            if (inputRequestFIFOs[i].canDeq) begin
                maybeIndex = tagged Valid i;
            end
        end
        if (maybeIndex matches tagged Valid .validIndex) begin
            let req = inputRequestFIFOs[validIndex].first;
            if (getsResponse(req)) begin
                pendingReqFIFO.enq(fromInteger(validIndex));
            end
            inputRequestFIFOs[validIndex].deq;
            server.request.enq(req);
        end
    endrule

    function ServerPort#(reqT, respT) genArbPort(Integer i);
        return (interface ServerPort;
                    interface InputPort request = toInputPort(inputRequestFIFOs[i]);
                    interface OutputPort response;
                        method respT first if (pendingReqFIFO.first == fromInteger(i));
                            return server.response.first;
                        endmethod
                        method Action deq if (pendingReqFIFO.first == fromInteger(i));
                            pendingReqFIFO.deq;
                            server.response.deq;
                        endmethod
                        method Bool canDeq;
                            if (pendingReqFIFO.canDeq && server.response.canDeq) begin
                                return pendingReqFIFO.first == fromInteger(i);
                            end else begin
                                return False;
                            end
                        endmethod
                    endinterface
                endinterface);
    endfunction

    Vector#(size,ServerPort#(reqT, respT)) ifc = genWith(genArbPort);
    return ifc;
endmodule

/**
 * This module takes a vector of `ServerPort`s and produces a single
 * `ServerPort` that can be used to acces them.
 */
module mkServerPortJoiner#(function Bit#(TLog#(size)) whichServer(reqT x), function Bool getsResponse(reqT x), Integer maxPendingReqs, Vector#(size, ServerPort#(reqT, respT)) servers)(ServerPort#(reqT, respT));
    // bookkeeping for pending requests and arbiter priority
    FIFOG#(Bit#(TLog#(size))) pendingReqFIFO <- mkSizedFIFOG(maxPendingReqs);

    interface InputPort request;
        method Action enq(reqT req);
            Bit#(TLog#(size)) i = whichServer(req);
            servers[i].request.enq(req);
            if (getsResponse(req)) begin
                pendingReqFIFO.enq(i);
            end
        endmethod
        method Bool canEnq;
            // Can't be of the exact value of this function unless we know the
            // request. This is just an approximation.
            return pendingReqFIFO.canEnq;
        endmethod
    endinterface
    interface OutputPort response;
        method respT first;
            let i = pendingReqFIFO.first;
            let resp = servers[i].response.first;
            return resp;
        endmethod
        method Action deq;
            let i = pendingReqFIFO.first;
            pendingReqFIFO.deq;
            servers[i].response.deq;
        endmethod
        method Bool canDeq;
            if (pendingReqFIFO.canDeq) begin
                let i = pendingReqFIFO.first;
                return servers[i].response.canDeq;
            end else begin
                return False;
            end
        endmethod
    endinterface
endmodule

/// There are many possible variations on this function (as seen in
/// `ClientServerUtil.bsv`), but currently this is the only one needed by the
/// Riscy processors.
function ServerPort#(req_in_t, resp_t) transformServerPortReq(function req_out_t f(req_in_t x), ServerPort#(req_out_t, resp_t) s);
    return (interface ServerPort;
                interface InputPort request;
                    method Action enq(req_in_t x);
                        s.request.enq( f(x) );
                    endmethod
                    method Bool canEnq;
                        return s.request.canEnq;
                    endmethod
                endinterface
                interface OutputPort response;
                    method resp_t first;
                        return s.response.first;
                    endmethod
                    method Action deq;
                        s.response.deq;
                    endmethod
                    method Bool canDeq;
                        return s.response.canDeq;
                    endmethod
                endinterface
            endinterface);
endfunction


endpackage
