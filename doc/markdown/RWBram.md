### [RWBram](../../src/bsv/RWBram.bsv#L27)
```bluespec
interface RWBram#(type addrT, type dataT);
    method Action wrReq(addrT a, dataT d);
    method Action rdReq(addrT a);
    method ActionValue#(dataT) rdResp;
endinterface


```

### [mkRWBram](../../src/bsv/RWBram.bsv#L33)
```bluespec
module mkRWBram(RWBram#(addrT, dataT)) provisos(
    Bits#(addrT, a__), Bits#(dataT, b__));

    BRAM_Configure cfg = defaultValue;
    BRAM2Port#(addrT, dataT) ram <- mkBRAM2Server(cfg);

    // port A: read
    // port B: write

    method Action wrReq(addrT a, dataT d);
        ram.portB.request.put(BRAMRequest {
            write: True,
            responseOnWrite: False,
            address: a,
            datain: d
        });
    endmethod

    method Action rdReq(addrT a);
        ram.portA.request.put(BRAMRequest {
            write: False,
            responseOnWrite: False,
            address: a,
            datain: ?
        });
    endmethod

    method ActionValue#(dataT) rdResp;
        let d <- ram.portA.response.get;
        return d;
    endmethod
endmodule

```

