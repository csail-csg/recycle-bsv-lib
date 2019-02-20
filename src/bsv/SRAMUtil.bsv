
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

/**
 * This package provides a collection of modules and interfaces for creating
 * and accessing SRAM cells. For FPGA and simulation targets, this package
 * uses the standard BRAM and BRAM_CORE packages. For ASIC targets, this
 * package can be used as placeholders for SRAMs generated by memory
 * compilers.
 */
package SRAMUtil;

import BRAMCore::*;
import RevertingVirtualReg::*;

import Ehr::*;

/// Single port SRAM interface
interface SRAM_1RW#(type addrT, type dataT);
    method Action req(Bool write, addrT a, dataT d);
    method dataT readData;
    method Action readDataDeq;
endinterface

/// Simple dual port SRAM interface (1 read port and 1 write port)
interface SRAM_1R1W#(type addrT, type dataT);
    // write port
    method Action writeReq(addrT a, dataT d);
    // read port
    method Action readReq(addrT a);
    method dataT readData;
    method Action readDataDeq;
endinterface

/// True dual port SRAM interface (2 read/write ports)
interface SRAM_2RW#(type addrT, type dataT);
    // port A
    interface SRAM_1RW#(addrT, dataT) a;
    // port B
    interface SRAM_1RW#(addrT, dataT) b;
endinterface

/**
 * Single-Port SRAM
 *
 * readData < readDataDeq < req
 */
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

/**
 * Simple Dual-Port SRAM
 *
 * A concurrent read and write to the same address will result in the read
 * seeing the *old* data.
 *
 * readData < readDataDeq < readReq < writeReq 
 */
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

/**
 * Simple Dual-Port SRAM with bypassing
 *
 * A concurrent read and write to the same address will result in the read
 * seeing the *new* data.
 *
 * readData < readDataDeq < readReq
 * writeReq < readReq
 * writeReq CF {readData, readDataDeq}
 */
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

/**
 * True Dual-Port SRAM.
 *
 * Has the additional constraint that a.req < b.req so that writes to port A
 * can be bypassed to reads from port B.
 */
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

endpackage