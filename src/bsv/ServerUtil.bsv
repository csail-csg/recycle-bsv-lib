
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

package ServerUtil;

import ClientServer::*;
import Ehr::*;
import FIFO::*;
import FIFOF::*;
import GetPut::*;
import SpecialFIFOs::*;
import Vector::*;

// port 0 has the highest priority
module mkFixedPriorityServerSplitter#(function Bool getsResponse(reqT x), Integer maxPendingReqs, Server#(reqT, respT) server)(Vector#(size,Server#(reqT, respT))) provisos (Bits#(reqT, reqTSz));
    Ehr#(TAdd#(size,1), Maybe#(Tuple2#(UInt#(TLog#(size)),reqT))) inputRequest <- mkEhr(tagged Invalid);

    // bookkeeping for pending requests and arbiter priority
    FIFO#(UInt#(TLog#(size))) pendingReqFIFO <- mkSizedFIFO(maxPendingReqs);

    rule forwardRequest (inputRequest[valueOf(size)] matches tagged Valid .index_req);
        let {i, req} = index_req;
        server.request.put(req);
        if (getsResponse(req)) begin
            pendingReqFIFO.enq(i);
        end
        inputRequest[valueOf(size)] <= tagged Invalid;
    endrule

    function Server#(reqT, respT) genArbPort(Integer i);
        return (interface Server;
                    interface Put request;
                        method Action put(reqT req) if (!isValid(inputRequest[i]));
                            inputRequest[i] <= tagged Valid tuple2(fromInteger(i), req);
                        endmethod
                    endinterface
                    interface Get response;
                        method ActionValue#(respT) get if (pendingReqFIFO.first == fromInteger(i));
                            pendingReqFIFO.deq;
                            let resp <- server.response.get;
                            return resp;
                        endmethod
                    endinterface
                endinterface);
    endfunction

    Vector#(size,Server#(reqT, respT)) ifc = genWith(genArbPort);
    return ifc;
endmodule

// By adding input buffers, there are no longer scheduling constraints between
// each of the output servers
module mkBufferedFixedPriorityServerSplitter#(function Bool getsResponse(reqT x), Integer maxPendingReqs, Server#(reqT, respT) server)(Vector#(size,Server#(reqT, respT))) provisos (Bits#(reqT, reqTSz));
    Vector#(size, FIFOF#(reqT)) inputRequestFIFOs <- replicateM(mkBypassFIFOF);

    // bookkeeping for pending requests and arbiter priority
    FIFO#(UInt#(TLog#(size))) pendingReqFIFO <- mkSizedFIFO(maxPendingReqs);

    rule forwardRequest;
        Maybe#(Integer) maybeIndex = tagged Invalid;
        for (Integer i = valueOf(size)-1 ; i >= 0 ; i = i - 1) begin
            if (inputRequestFIFOs[i].notEmpty) begin
                maybeIndex = tagged Valid i;
            end
        end
        if (maybeIndex matches tagged Valid .validIndex) begin
            let req = inputRequestFIFOs[validIndex].first;
            if (getsResponse(req)) begin
                pendingReqFIFO.enq(fromInteger(validIndex));
            end
            inputRequestFIFOs[validIndex].deq;
            server.request.put(req);
        end
    endrule

    function Server#(reqT, respT) genArbPort(Integer i);
        return (interface Server;
                    interface Put request;
                        method Action put(reqT req);
                            inputRequestFIFOs[i].enq(req);
                        endmethod
                    endinterface
                    interface Get response;
                        method ActionValue#(respT) get if (pendingReqFIFO.first == fromInteger(i));
                            pendingReqFIFO.deq;
                            let resp <- server.response.get;
                            return resp;
                        endmethod
                    endinterface
                endinterface);
    endfunction

    Vector#(size,Server#(reqT, respT)) ifc = genWith(genArbPort);
    return ifc;
endmodule

module mkServerJoiner#(function Bit#(TLog#(size)) whichServer(reqT x), function Bool getsResponse(reqT x), Integer maxPendingReqs, Vector#(size, Server#(reqT, respT)) servers)(Server#(reqT, respT));
    // bookkeeping for pending requests and arbiter priority
    FIFO#(Bit#(TLog#(size))) pendingReqFIFO <- mkSizedFIFO(maxPendingReqs);

    interface Put request;
        method Action put(reqT req);
            Bit#(TLog#(size)) i = whichServer(req);
            servers[i].request.put(req);
            if (getsResponse(req)) begin
                pendingReqFIFO.enq(i);
            end
        endmethod
    endinterface
    interface Get response;
        method ActionValue#(respT) get;
            let i = pendingReqFIFO.first;
            pendingReqFIFO.deq;
            let resp <- servers[i].response.get;
            return resp;
        endmethod
    endinterface
endmodule

endpackage
