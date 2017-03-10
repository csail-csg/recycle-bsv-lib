## mkFixedPriorityServerSplitter
```bluespec
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


```

## mkBufferedFixedPriorityServerSplitter
```bluespec
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


```

## mkServerJoiner
```bluespec
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


```

