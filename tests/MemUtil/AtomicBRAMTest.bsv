
// Copyright (c) 2017 Massachusetts Institute of Technology

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

import StmtFSM::*;

import MemUtil::*;
import Port::*;

typedef 2 LogNumBytes;
typedef 32 DataSz;
typedef 32 AddrSz;
typedef 1024 NumWords;

(* synthesize *)
module mkAtomicBRAMTest(Empty);
    Reg#(Bool) init <- mkReg(False);
    AtomicBRAM#(AddrSz, LogNumBytes, NumWords) atomicBRAM <- mkAtomicBRAM;

    function Action sendRequest(Bit#(4) write_en, AtomicMemOp atomic_op, Bit#(AddrSz) addr, Bit#(DataSz) data);
        return (action
                atomicBRAM.portA.request.enq( AtomicMemReq { write_en: write_en, atomic_op: atomic_op, addr: addr, data: data } );
            endaction);
    endfunction

    function Action checkResponse(Bool write, Maybe#(Bit#(32)) data);
        return (action
                Bool err = False;
                if (atomicBRAM.portA.response.first.write != write) begin
                    err = True;
                end
                if (data matches tagged Valid .validData) begin
                    if (atomicBRAM.portA.response.first.data != validData) begin
                        err = True;
                    end
                end
                if (err) begin
                    $display("[ERROR] checkResponse(", fshow(write), ", ", fshow(data), ") failed");
                    $display("        actual response was (", fshow(atomicBRAM.portA.response.first.write), ", ", fshow(atomicBRAM.portA.response.first.data), ")");
                end
                atomicBRAM.portA.response.deq;
            endaction);
    endfunction

    Reg#(Bit#(32)) i <- mkReg(0);
    Reg#(Bit#(32)) j <- mkReg(0);
    Reg#(Bit#(32)) timer <- mkReg(0);
    Reg#(Bit#(32)) timeCmp <- mkReg(0);

    rule incTimer;
        timer <= timer + 1;
    endrule

    function Stmt initAtomicTest( Bit#(32) init_mem );
        return (seq
                    sendRequest('1, None, 0, init_mem);
                    checkResponse(True, tagged Invalid);
                endseq);
    endfunction

    function Stmt atomicTest( Bit#(4) write_en, AtomicMemOp atomic_op, Bit#(32) init_mem, Bit#(32) operand, Bit#(32) final_result );
        return (seq
                    sendRequest(write_en, atomic_op, 0, operand);
                    checkResponse(True, tagged Valid init_mem); // old value
                    sendRequest(0, None, 0, 0);
                    checkResponse(False, tagged Valid final_result); // new value
                endseq);
    endfunction

    Stmt atomicBRAMTest =
        (seq
            $display("Starting test");
            // simple test
            sendRequest('1, None, 0, 42);
            checkResponse(True, tagged Invalid);
            sendRequest('1, None, 0, 64);
            checkResponse(True, tagged Invalid);
            sendRequest('1, None, 0, 122);
            checkResponse(True, tagged Invalid);
            sendRequest('1, None, 0, 17);
            checkResponse(True, tagged Invalid);
            sendRequest(0, None, 0, 101);
            checkResponse(False, tagged Valid 17);

            // time writing
            timeCmp <= timer;
            par
                seq
                    i <= 0;
                    while (i < fromInteger(valueOf(NumWords) * 4)) action
                        sendRequest('1, None, i, ~i);
                        i <= i + 4;
                    endaction
                endseq
                seq
                    j <= 0;
                    while (j < fromInteger(valueOf(NumWords) * 4)) action
                        checkResponse(True, tagged Invalid);
                        j <= j + 4;
                    endaction
                endseq
            endpar
            timeCmp <= timer - timeCmp;
            $display("Writing %0d words takes %0d cycles", valueOf(NumWords), timeCmp);

            // time reading
            timeCmp <= timer;
            par
                seq
                    i <= fromInteger((valueOf(NumWords) - 1) * 4);
                    while (i > 0) action
                        sendRequest(0, None, i, ~i);
                        i <= (i - 4);
                    endaction
                    sendRequest(0, None, 0, ~0);
                endseq
                seq
                    j <= fromInteger((valueOf(NumWords) - 1) * 4);
                    while (j > 0) action
                        checkResponse(False, tagged Valid (~j));
                        j <= (j - 4);
                    endaction
                    checkResponse(False, tagged Valid (~0));
                endseq
            endpar
            timeCmp <= timer - timeCmp;
            $display("Reading %0d words takes %0d cycles", valueOf(NumWords), timeCmp);

            // time atomic add
            timeCmp <= timer;
            par
                seq
                    i <= fromInteger((valueOf(NumWords) - 1) * 4);
                    while (i > 0) action
                        sendRequest('1, Add, i, 1);
                        i <= (i - 4);
                    endaction
                    sendRequest('1, Add, i, 1);
                endseq
                seq
                    j <= fromInteger((valueOf(NumWords) - 1) * 4);
                    while (j > 0) action
                        checkResponse(True, tagged Valid (~j));
                        j <= (j - 4);
                    endaction
                    checkResponse(True, tagged Valid (~0));
                endseq
            endpar
            timeCmp <= timer - timeCmp;
            $display("Adding 1 to %0d words takes %0d cycles", valueOf(NumWords), timeCmp);

            // checking results of atomic add
            par
                seq
                    i <= fromInteger((valueOf(NumWords) - 1) * 4);
                    while (i > 0) action
                        sendRequest(0, None, i, ~i);
                        i <= (i - 4);
                    endaction
                    sendRequest(0, None, 0, ~0);
                endseq
                seq
                    j <= fromInteger((valueOf(NumWords) - 1) * 4);
                    while (j > 0) action
                        checkResponse(False, tagged Valid (1 + ~j));
                        j <= (j - 4);
                    endaction
                    checkResponse(False, tagged Valid (1 + ~0));
                endseq
            endpar

            // some more basic tests
            initAtomicTest( 32'h87654321 );
            atomicTest( 4'b1111, Swap, 32'h87654321, 32'hCAFEF00D, 32'hCAFEF00D );
            atomicTest( 4'b0110, Swap, 32'hCAFEF00D, 32'h31BD00F6, 32'hCABD000D );
            atomicTest( 4'b1111, Add,  32'hCABD000D, 32'h80808080, 32'h4B3D808D );
            atomicTest( 4'b0011, Add,  32'h4B3D808D, 32'h80808080, 32'h4B3D010D );
            atomicTest( 4'b1101, Xor,  32'h4B3D010D, 32'h44320E02, 32'h0F0F010F );
            atomicTest( 4'b1011, And,  32'h0F0F010F, 32'h0FF7F711, 32'h0F0F0101 );
            atomicTest( 4'b1011, Or,   32'h0F0F0101, 32'hF01F0EFF, 32'hFF0F0FFF );
            atomicTest( 4'b1111, Min,  32'hFF0F0FFF, 32'h12345678, 32'hFF0F0FFF );
            atomicTest( 4'b1111, Min,  32'hFF0F0FFF, 32'hF00000FF, 32'hF00000FF );
            atomicTest( 4'b0011, Min,  32'hF00000FF, 32'h82345678, 32'hF00000FF );
            atomicTest( 4'b0011, Min,  32'hF00000FF, 32'h0237F000, 32'hF000F000 );
            atomicTest( 4'b1100, Min,  32'hF000F000, 32'h02378000, 32'hF000F000 );
            atomicTest( 4'b1100, Min,  32'hF000F000, 32'h80000000, 32'h8000F000 );
            atomicTest( 4'b0110, Min,  32'h8000F000, 32'h8000F100, 32'h8000F000 );
            atomicTest( 4'b0110, Min,  32'h8000F000, 32'h8000EF00, 32'h8000EF00 );

            initAtomicTest( 32'h81820304 );
            atomicTest( 4'b0001, Max,  32'h81820304, 32'h80000003, 32'h81820304 );
            atomicTest( 4'b0001, Max,  32'h81820304, 32'h80000005, 32'h81820305 );
            atomicTest( 4'b0100, Max,  32'h81820305, 32'h00830000, 32'h81830305 );

            initAtomicTest( 32'h81820304 );
            atomicTest( 4'b0001, Minu,  32'h81820304, 32'h00000005, 32'h81820304 );
            atomicTest( 4'b0001, Minu,  32'h81820304, 32'h80000003, 32'h81820303 );
            atomicTest( 4'b0100, Minu,  32'h81820303, 32'h00880000, 32'h81820303 );
            atomicTest( 4'b0100, Minu,  32'h81820303, 32'h00810000, 32'h81810303 );

            initAtomicTest( 32'h81820304 );
            atomicTest( 4'b0001, Maxu,  32'h81820304, 32'h80000003, 32'h81820304 );
            atomicTest( 4'b0001, Maxu,  32'h81820304, 32'h00000005, 32'h81820305 );
            atomicTest( 4'b0100, Maxu,  32'h81820305, 32'h00810000, 32'h81820305 );
            atomicTest( 4'b0100, Maxu,  32'h81820305, 32'h00880000, 32'h81880305 );
        endseq);

    mkAutoFSM(atomicBRAMTest);
endmodule
