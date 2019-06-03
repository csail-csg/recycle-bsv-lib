import RegFile::*;
import Vector::*;

// I want something like this:
//     NumBits#(64) = NumBytes#(8) = LogNumBytes#(3)
// typedef NumBits#(TMul#(n,8)) NumBytes#(numeric type n);
// typedef NumBytes#(TExp#(n)) LogNumBytes#(numeric type n);

interface SRAMCore1RW#(type addrT, type dataT);
    (* always_ready *)
    method Action req(Bool write, addrT addr, dataT writeData);
    (* always_ready *) 
    method dataT readData;
endinterface

import "BVI" SRAM_1RW =
module mkSRAMCore1RW(SRAMCore1RW#(addrT, dataT)) provisos (Bits#(addrT, addrSz), Bits#(dataT, dataSz));
    parameter ADDR_SZ = valueOf(addrSz);
    parameter DATA_SZ = valueOf(dataSz);
    parameter MEM_SZ = valueOf(TExp#(addrSz));

    default_clock clk(clk);
    default_reset no_reset;

    method req(write, addr, write_data) enable (en);
    method read_data readData();

    schedule (readData) SB (req);
    schedule (req) C (req);
    schedule (readData) CF (readData);
endmodule

(* synthesize *)
module mkSRAM_1RW_6_22(SRAMCore1RW#(Bit#(6), Bit#(22)));
    SRAMCore1RW#(Bit#(6), Bit#(22)) sram <- mkSRAMCore1RW;
    return sram;
endmodule

interface SRAMCore1R1W#(type addrT, type dataT);
    (* always_ready *)
    method Action writeReq(addrT addr, dataT data);
    (* always_ready *)
    method Action readReq(addrT addr);
    (* always_ready *)
    method dataT readData;
endinterface

import "BVI" SRAM_1R1W =
module mkSRAMCore1R1W(SRAMCore1R1W#(addrT, dataT)) provisos (Bits#(addrT, addrSz), Bits#(dataT, dataSz));
    parameter ADDR_SZ = valueOf(addrSz);
    parameter DATA_SZ = valueOf(dataSz);
    parameter MEM_SZ = valueOf(TExp#(addrSz));

    default_clock clk(clk);
    default_reset no_reset;

    method writeReq(write_addr, write_data) enable (write_en);
    method readReq(read_addr) enable (read_en);
    method read_data readData();

    schedule (readData) SB (readReq);
    schedule (readData) CF (writeReq);
    schedule (readReq) SB (writeReq);
    schedule (writeReq) C (writeReq);
    schedule (readReq) C (readReq);
    schedule (readData) CF (readData);
endmodule

module mkSRAMCore1R1W_RegFileModel(SRAMCore1R1W#(addrT, dataT))
        provisos(
            Bounded#(addrT),
            Bits#(addrT, addrSz),
            Bits#(dataT, dataSz)
        );
    RegFile#(addrT, dataT) rf <- mkRegFileFull;

    Reg#(dataT) readReg <- mkRegU;

    method Action writeReq(addrT addr, dataT data);
        rf.upd(addr, data);
    endmethod
    method Action readReq(addrT addr);
        readReg <= rf.sub(addr);
    endmethod
    method dataT readData;
        return readReg;
    endmethod
endmodule

////////////////////////////////////////////////////////////////////////////////

interface SRAMCore1R1W_BE#(numeric type addrSz, numeric type dataSz);
    (* always_ready *)
    method Action writeReq(Bit#(TDiv#(dataSz, 8)) byte_en, Bit#(addrSz) addr, Bit#(dataSz) data);
    (* always_ready *)
    method Action readReq(Bit#(addrSz) addr);
    (* always_ready *)
    method Bit#(dataSz) readData;
endinterface

import "BVI" SRAM_1R1W_BE =
module mkSRAMCore1R1W_BE(SRAMCore1R1W_BE#(addrSz, dataSz));
    parameter ADDR_SZ = valueOf(addrSz);
    parameter DATA_SZ_BYTES = valueOf(TDiv#(dataSz, 8));
    parameter MEM_SZ = valueOf(TExp#(addrSz));

    default_clock clk(clk);
    default_reset no_reset;

    method writeReq(write_bytes, write_addr, write_data) enable (write_en);
    method readReq(read_addr) enable (read_en);
    method read_data readData();

    schedule (readData) SB (readReq);
    schedule (readData) CF (writeReq);
    schedule (readReq) SB (writeReq);
    schedule (writeReq) C (writeReq);
    schedule (readReq) C (readReq);
    schedule (readData) CF (readData);
endmodule

module mkSRAMCore1R1W_BE_RegFileModel(SRAMCore1R1W_BE#(addrSz, dataSz)) provisos (Add#(a__, dataSz, TMul#(TDiv#(dataSz, 8), 8)));
    RegFile#(Bit#(addrSz), Bit#(dataSz)) rf <- mkRegFileFull;

    Reg#(Bit#(dataSz)) readReg <- mkRegU;

    method Action writeReq(Bit#(TDiv#(dataSz, 8)) byte_en, Bit#(addrSz) addr, Bit#(dataSz) data);
        let x = rf.sub(addr);
        Vector#(TDiv#(dataSz, 8), Bit#(8)) data_in = unpack(zeroExtend(data));
        // write_data is initialized with current data
        Vector#(TDiv#(dataSz, 8), Bit#(8)) write_data = unpack(zeroExtend(x));
        for (Integer i = 0 ; i < valueOf(TDiv#(dataSz,8)) ; i = i+1) begin
            if (byte_en[i] == 1) begin
                write_data[i] = data_in[i];
            end
        end
        rf.upd(addr, truncate(pack(write_data)));
    endmethod
    method Action readReq(Bit#(addrSz) addr);
        readReg <= rf.sub(addr);
    endmethod
    method Bit#(dataSz) readData;
        return readReg;
    endmethod
endmodule
