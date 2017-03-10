
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

package Port;

import ClientServer::*;
import Connectable::*;
import Ehr::*;
import FIFOG::*;
import GetPut::*;

/**
 * This package defines "Port" interfaces intended to replace Get, Put,
 * Client, and Server. The InputPort interface improves upon the Put interface
 * by adding a canEnq method. The OutputPort interface improves upon the Get
 * interfaces by separating get into first and deq methods and also including
 * a canDeq method.
 *
 * The ServerPort and ClientPort are replacement Server and Client interfaces
 * that use InputPort and OutputPort instead of Get and Put.
 *
 * This package contains two ways to convert interfaces to InputPort and
 * OutputPort. The first way are the functions toInputPort and toOutputPort.
 * These functions. Currently there are no concrete implementations of these
 * functions,
 */

interface InputPort#(type t);
    method Action enq(t val);
    method Bool canEnq;
endinterface

interface OutputPort#(type t);
    method Bool canDeq;
    method t first;
    method Action deq;
endinterface

interface ServerPort#(type req_t, type resp_t);
    interface InputPort#(req_t) request;
    interface OutputPort#(resp_t) response;
endinterface

interface ClientPort#(type req_t, type resp_t);
    interface OutputPort#(req_t) request;
    interface InputPort#(resp_t) response;
endinterface

typeclass ToInputPort#(type in_t, type port_t);
    function InputPort#(port_t) toInputPort(in_t x);
endtypeclass

typeclass ToOutputPort#(type in_t, type port_t);
    function OutputPort#(port_t) toOutputPort(in_t x);
endtypeclass

typeclass MkInputPortBuffer#(type in_t, type port_t);
    module mkInputPortBuffer#(in_t x)(InputPort#(port_t));
    module mkInputPortBypassBuffer#(in_t x)(InputPort#(port_t));
endtypeclass

typeclass MkOutputPortBuffer#(type in_t, type port_t);
    module mkOutputPortBuffer#(in_t x)(OutputPort#(port_t));
    module mkOutputPortBypassBuffer#(in_t x)(OutputPort#(port_t));
endtypeclass

// Instances
instance Connectable#(OutputPort#(t), InputPort#(t));
    module mkConnection#(OutputPort#(t) a, InputPort#(t) b)(Empty);
        rule connection;
            a.deq();
            b.enq(a.first);
        endrule
    endmodule
endinstance

instance Connectable#(InputPort#(t), OutputPort#(t));
    module mkConnection#(InputPort#(t) a, OutputPort#(t) b)(Empty);
        rule connection;
            b.deq();
            a.enq(b.first);
        endrule
    endmodule
endinstance

instance Connectable#(ServerPort#(req_t, resp_t), ClientPort#(req_t, resp_t));
    module mkConnection#(ServerPort#(req_t, resp_t) a, ClientPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance

instance Connectable#(ClientPort#(req_t, resp_t), ServerPort#(req_t, resp_t));
    module mkConnection#(ClientPort#(req_t, resp_t) a, ServerPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance

// connecting with Put#(t)
instance Connectable#(OutputPort#(t), Put#(t));
    module mkConnection#(OutputPort#(t) a, Put#(t) b)(Empty);
        rule connection;
            a.deq();
            b.put(a.first);
        endrule
    endmodule
endinstance

instance Connectable#(Put#(t), OutputPort#(t));
    module mkConnection#(Put#(t) a, OutputPort#(t) b)(Empty);
        rule connection;
            b.deq();
            a.put(b.first);
        endrule
    endmodule
endinstance

// connecting with Get#(t)
instance Connectable#(Get#(t), InputPort#(t));
    module mkConnection#(Get#(t) a, InputPort#(t) b)(Empty);
        rule connection;
            let val <- a.get();
            b.enq(val);
        endrule
    endmodule
endinstance

instance Connectable#(InputPort#(t), Get#(t));
    module mkConnection#(InputPort#(t) a, Get#(t) b)(Empty);
        rule connection;
            let val <- b.get();
            a.enq(val);
        endrule
    endmodule
endinstance

// connecting with Client#(req_t,resp_t)
instance Connectable#(ServerPort#(req_t, resp_t), Client#(req_t, resp_t));
    module mkConnection#(ServerPort#(req_t, resp_t) a, Client#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance

instance Connectable#(Client#(req_t, resp_t), ServerPort#(req_t, resp_t));
    module mkConnection#(Client#(req_t, resp_t) a, ServerPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance

// connecting with Server#(req_t,resp_t)
instance Connectable#(Server#(req_t, resp_t), ClientPort#(req_t, resp_t));
    module mkConnection#(Server#(req_t, resp_t) a, ClientPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance

instance Connectable#(ClientPort#(req_t, resp_t), Server#(req_t, resp_t));
    module mkConnection#(ClientPort#(req_t, resp_t) a, Server#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance

instance ToInputPort#(FIFOG#(port_t), port_t);
    function InputPort#(port_t) toInputPort(FIFOG#(port_t) x);
        return (interface InputPort;
                method Action enq(port_t val);
                    x.enq(val);
                endmethod
                method Bool canEnq();
                    return x.canEnq();
                endmethod
            endinterface);
    endfunction
endinstance

instance ToOutputPort#(FIFOG#(port_t), port_t);
    function OutputPort#(port_t) toOutputPort(FIFOG#(port_t) x);
        return (interface OutputPort;
                method Bool canDeq();
                    return x.canDeq();
                endmethod
                method port_t first();
                    return x.first();
                endmethod
                method Action deq();
                    x.deq();
                endmethod
            endinterface);
    endfunction
endinstance

// If you can do toInputPort(x), you can do mkInputPortBuffer(x)
instance MkInputPortBuffer#(in_t, port_t) provisos (ToInputPort#(in_t, port_t));
    module mkInputPortBuffer#(in_t x)(InputPort#(port_t));
        return toInputPort(x);
    endmodule
    module mkInputPortBypassBuffer#(in_t x)(InputPort#(port_t));
        return toInputPort(x);
    endmodule
endinstance

// If you can do toOutputPort(x), you can do mkOutputPortBuffer(x)
instance MkOutputPortBuffer#(in_t, port_t) provisos (ToOutputPort#(in_t, port_t));
    module mkOutputPortBuffer#(in_t x)(OutputPort#(port_t));
        return toOutputPort(x);
    endmodule
    module mkOutputPortBypassBuffer#(in_t x)(OutputPort#(port_t));
        return toOutputPort(x);
    endmodule
endinstance

instance MkInputPortBuffer#(Put#(t), t) provisos (Bits#(t, tSz));
    module mkInputPortBuffer#(Put#(t) x)(InputPort#(t));
        Ehr#(2, Maybe#(t)) put_buffer <- mkEhr(tagged Invalid);

        rule doPut(put_buffer[0] matches tagged Valid .val);
            x.put(val);
            put_buffer[0] <= tagged Invalid;
        endrule

        method Action enq(t val) if (!isValid(put_buffer[1]));
            put_buffer[1] <= tagged Valid val;
        endmethod

        method Bool canEnq();
            return !isValid(put_buffer[1]);
        endmethod
    endmodule
    module mkInputPortBypassBuffer#(Put#(t) x)(InputPort#(t));
        Ehr#(2, Maybe#(t)) put_buffer <- mkEhr(tagged Invalid);

        rule doPut(put_buffer[1] matches tagged Valid .val);
            x.put(val);
            put_buffer[1] <= tagged Invalid;
        endrule

        method Action enq(t val) if (!isValid(put_buffer[0]));
            put_buffer[0] <= tagged Valid val;
        endmethod

        method Bool canEnq();
            return !isValid(put_buffer[0]);
        endmethod
    endmodule
endinstance

instance MkOutputPortBuffer#(Get#(t), t) provisos (Bits#(t, tSz));
    module mkOutputPortBuffer#(Get#(t) x)(OutputPort#(t));
        Ehr#(2, Maybe#(t)) get_buffer <- mkEhr(tagged Invalid);

        rule doGet(!isValid(get_buffer[1]));
            let val <- x.get();
            get_buffer[1] <= tagged Valid val;
        endrule

        method Bool canDeq();
            return isValid(get_buffer[0]);
        endmethod
        method t first() if (get_buffer[0] matches tagged Valid .val);
            return val;
        endmethod
        method Action deq() if (isValid(get_buffer[0]));
            get_buffer[0] <= tagged Invalid;
        endmethod
    endmodule
    module mkOutputPortBypassBuffer#(Get#(t) x)(OutputPort#(t));
        Ehr#(2, Maybe#(t)) get_buffer <- mkEhr(tagged Invalid);

        rule doGet(!isValid(get_buffer[0]));
            let val <- x.get();
            get_buffer[0] <= tagged Valid val;
        endrule

        method Bool canDeq();
            return isValid(get_buffer[1]);
        endmethod
        method t first() if (get_buffer[1] matches tagged Valid .val);
            return val;
        endmethod
        method Action deq() if (isValid(get_buffer[1]));
            get_buffer[1] <= tagged Invalid;
        endmethod
    endmodule
endinstance

endpackage