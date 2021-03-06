# SRAMUtil


This package provides a collection of modules and interfaces for creating
and accessing SRAM cells. For FPGA and simulation targets, this package
uses the standard BRAM and BRAM_CORE packages. For ASIC targets, this
package can be used as placeholders for SRAMs generated by memory
compilers.


### [SRAM_1RW](../../src/bsv/SRAMUtil.bsv#L39)

Single port SRAM interface
```bluespec
interface SRAM_1RW#(type addrT, type dataT);
    method Action req(Bool write, addrT a, dataT d);
    method dataT readData;
    method Action readDataDeq;
endinterface


```

### [SRAM_1R1W](../../src/bsv/SRAMUtil.bsv#L46)

Simple dual port SRAM interface (1 read port and 1 write port)
```bluespec
interface SRAM_1R1W#(type addrT, type dataT);
    // write port
    method Action writeReq(addrT a, dataT d);
    // read port
    method Action readReq(addrT a);
    method dataT readData;
    method Action readDataDeq;
endinterface


```

### [SRAM_2RW](../../src/bsv/SRAMUtil.bsv#L56)

True dual port SRAM interface (2 readwrite ports)
```bluespec
interface SRAM_2RW#(type addrT, type dataT);
    // port A
    interface SRAM_1RW#(addrT, dataT) a;
    // port B
    interface SRAM_1RW#(addrT, dataT) b;
endinterface


```

### [mkSRAM_1RW](../../src/bsv/SRAMUtil.bsv#L68)


Single-Port SRAM

readData < readDataDeq < req

```bluespec
module mkSRAM_1RW( SRAM_1RW#(addrT, dataT) ) provisos (Bits#(addrT, addrSz), Bits#(dataT, dataSz));
    Integer memSz = valueOf(TExp#(addrSz));
    Bool hasOutputRegister = False;
    BRAM_PORT#(addrT, dataT) bram <- mkBRAMCore1(memSz, hasOutputRegister);

    Ehr#(2, Bool) readPending <- mkEhr(False);

    method Action req(Bool write, addrT a, dataT d) if (!readPending[1]);
        bram.put(write, a, d);
        if (!write) begin
            readPending[1] <= True;
        end
    endmethod
    method dataT readData if (readPending[0]);
        return bram.read;
    endmethod
    method Action readDataDeq;
        readPending[0] <= False;
    endmethod
endmodule


```

### [mkSRAM_1R1W](../../src/bsv/SRAMUtil.bsv#L97)


Simple Dual-Port SRAM

A concurrent read and write to the same address will result in the read
seeing theolddata.

readData < readDataDeq < readReq < writeReq 

```bluespec
module mkSRAM_1R1W( SRAM_1R1W#(addrT, dataT) ) provisos (Bits#(addrT, addrSz), Bits#(dataT, dataSz));
    Integer memSz = valueOf(TExp#(addrSz));
    Bool hasOutputRegister = False;
    BRAM_DUAL_PORT#(addrT, dataT) bram <- mkBRAMCore2(memSz, hasOutputRegister);

    Ehr#(2, Bool) readPending <- mkEhr(False);
    Reg#(Bool) _rvr_readReq_sb_writeReq <- mkRevertingVirtualReg(True);

    method Action writeReq(addrT a, dataT d);
        bram.a.put(True, a, d);

        // reverting virtual register for scheduling purposes
        _rvr_readReq_sb_writeReq <= False;
    endmethod

    method Action readReq(addrT a) if (!readPending[1] && _rvr_readReq_sb_writeReq);
        bram.b.put(False, a, unpack(0));
        readPending[1] <= True;
    endmethod
    method dataT readData if (readPending[0]);
        return bram.b.read;
    endmethod
    method Action readDataDeq;
        readPending[0] <= False;
    endmethod
endmodule


```

### [mkSRAM_1R1W_Bypass](../../src/bsv/SRAMUtil.bsv#L134)


Simple Dual-Port SRAM with bypassing

A concurrent read and write to the same address will result in the read
seeing thenewdata.

readData < readDataDeq < readReq
writeReq < readReq
writeReq CF {readData, readDataDeq}

```bluespec
module mkSRAM_1R1W_Bypass( SRAM_1R1W#(addrT, dataT) ) provisos (Bits#(addrT, addrSz), Bits#(dataT, dataSz));
    Integer memSz = valueOf(TExp#(addrSz));
    Bool hasOutputRegister = False;
    BRAM_DUAL_PORT#(addrT, dataT) bram <- mkBRAMCore2(memSz, hasOutputRegister);

    Ehr#(2, Bool) readPending <- mkEhr(False);
    Ehr#(2, Maybe#(dataT)) bypassData <- mkEhr(tagged Invalid);

    Wire#(Maybe#(Tuple2#(addrT, dataT))) writeReqWire <- mkDWire(tagged Invalid);

    method Action writeReq(addrT a, dataT d);
        bram.a.put(True, a, d);
        writeReqWire <= tagged Valid tuple2(a, d);
    endmethod

    method Action readReq(addrT a) if (!readPending[1]);
        bram.b.put(False, a, unpack(0));
        readPending[1] <= True;
        if (writeReqWire matches tagged Valid {.writeAddr, .writeData} &&& pack(writeAddr) == pack(a)) begin
            bypassData[1] <= tagged Valid writeData;
        end
    endmethod
    method dataT readData if (readPending[0]);
        if (bypassData[0] matches tagged Valid .bypassData) begin
            return bypassData;
        end else begin
            return bram.b.read;
        end
    endmethod
    method Action readDataDeq;
        readPending[0] <= False;
        if (isValid(bypassData[0])) begin
            bypassData[0] <= tagged Invalid;
        end
    endmethod
endmodule


```

### [mkSRAM_2RW](../../src/bsv/SRAMUtil.bsv#L177)


True Dual-Port SRAM.

Has the additional constraint that a.req < b.req so that writes to port A
can be bypassed to reads from port B.

```bluespec
module mkSRAM_2RW( SRAM_2RW#(addrT, dataT) ) provisos (Bits#(addrT, addrSz), Bits#(dataT, dataSz));
    Integer memSz = 0;
    Bool hasOutputRegister = False;
    BRAM_DUAL_PORT#(addrT, dataT) bram <- mkBRAMCore2(memSz, hasOutputRegister);

    Ehr#(2, Bool) readPendingA <- mkEhr(False);
    Ehr#(2, Bool) readPendingB <- mkEhr(False);

    // This is for bypassing writes to port A to reads from port B
    Ehr#(2, Maybe#(dataT)) bypassData <- mkEhr(tagged Invalid);
    Wire#(Maybe#(Tuple2#(addrT, dataT))) writeReqWire <- mkDWire(tagged Invalid);

    interface SRAM_1RW a;
        method Action req(Bool write, addrT a, dataT d) if (!readPendingA[1]);
            bram.a.put(write, a, d);
            if (!write) begin
                readPendingA[1] <= True;
            end else begin
                writeReqWire <= tagged Valid tuple2(a, d);
            end
        endmethod
        method dataT readData if (readPendingA[0]);
            return bram.a.read;
        endmethod
        method Action readDataDeq;
            readPendingA[0] <= False;
        endmethod
    endinterface
    interface SRAM_1RW b;
        method Action req(Bool write, addrT a, dataT d) if (!readPendingB[1]);
            bram.b.put(write, a, d);
            if (!write) begin
                readPendingB[1] <= True;
                if (writeReqWire matches tagged Valid {.writeAddr, .writeData} &&& pack(writeAddr) == pack(a)) begin
                    // bypassing from port A
                    bypassData[1] <= tagged Valid writeData;
                end
            end
        endmethod
        method dataT readData if (readPendingB[0]);
            if (bypassData[1] matches tagged Valid .bypass) begin
                return bypass;
            end else begin
                return bram.b.read;
            end
        endmethod
        method Action readDataDeq;
            readPendingB[0] <= False;
            if (isValid(bypassData[0])) begin
                bypassData[0] <= tagged Invalid;
            end
        endmethod
    endinterface
endmodule


```

