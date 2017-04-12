# Port


This package defines "Port" interfaces intended to replace `Get`, `Put`,
`Client`, and `Server`. The `InputPort` interface improves upon the `Put`
interface by adding a `canEnq` method. The `OutputPort` interface improves
upon the `Get` interfaces by separating `get` into `first` and `deq` methods
and also including a `canDeq` method.

The `ServerPort` and `ClientPort` interfaces are replacements `Server` and
`Client` interfaces that use `InputPort` and `OutputPort` instead of `Get`
and `Put`.

This package contains two ways to convert interfaces to `InputPort` and
`OutputPort`. The first way are the functions `toInputPort` and
`toOutputPort`. These functions are only defined for interfaces that can
be directly converted to `InputPort` or `OutputPort` with minimal logic.
The second way are the modules `mkInputPortBuffer`,
`mkInputPortBypassBuffer`, `mkOutputPortBuffer`, `mkOutputPortBypassBuffer`.
These modules add a buffers to the inputted interface to create `InputPort`
or `OutputPort` interfaces. Since these add buffers, they break the
atomicity of the action of the inputted interface.


### [InputPort](../../src/bsv/Port.bsv#L54)
```bluespec
interface InputPort#(type t);
    method Action enq(t val);
    method Bool canEnq;
endinterface


```

### [OutputPort](../../src/bsv/Port.bsv#L59)
```bluespec
interface OutputPort#(type t);
    method Bool canDeq;
    method t first;
    method Action deq;
endinterface


```

### [nullInputPort](../../src/bsv/Port.bsv#L68)

This is only a function because our documentation system cannot handle
top-level variable definitions. This function and other functions like it
can be used as if it was defined as if it were just a variable.
```bluespec
function InputPort#(t) nullInputPort;
    return (interface InputPort;
            method Action enq(t val) if (False);
                noAction;
            endmethod
            method canEnq;
                return False;
            endmethod
        endinterface);
endfunction


```

### [nullOutputPort](../../src/bsv/Port.bsv#L79)
```bluespec
function OutputPort#(t) nullOutputPort;
    return (interface OutputPort;
            method t first if (False);
                return ?;
            endmethod
            method Action deq if (False);
                noAction;
            endmethod
            method Bool canDeq;
                return False;
            endmethod
        endinterface);
endfunction


```

### [ServerPort](../../src/bsv/Port.bsv#L93)
```bluespec
interface ServerPort#(type req_t, type resp_t);
    interface InputPort#(req_t) request;
    interface OutputPort#(resp_t) response;
endinterface


```

### [ClientPort](../../src/bsv/Port.bsv#L98)
```bluespec
interface ClientPort#(type req_t, type resp_t);
    interface OutputPort#(req_t) request;
    interface InputPort#(resp_t) response;
endinterface


```

### [nullServerPort](../../src/bsv/Port.bsv#L103)
```bluespec
function ServerPort#(req_t, resp_t) nullServerPort;
    return (interface ServerPort;
            interface InputPort request = nullInputPort;
            interface OutputPort response = nullOutputPort;
        endinterface);
endfunction


```

### [nullClientPort](../../src/bsv/Port.bsv#L110)
```bluespec
function ClientPort#(req_t, resp_t) nullClientPort;
    return (interface ClientPort;
            interface OutputPort request = nullOutputPort;
            interface InputPort response = nullInputPort;
        endinterface);
endfunction


```

### [ToInputPort](../../src/bsv/Port.bsv#L117)
```bluespec
typeclass ToInputPort#(type in_t, type port_t);
    function InputPort#(port_t) toInputPort(in_t x);
endtypeclass


```

### [ToOutputPort](../../src/bsv/Port.bsv#L121)
```bluespec
typeclass ToOutputPort#(type in_t, type port_t);
    function OutputPort#(port_t) toOutputPort(in_t x);
endtypeclass


```

### [MkInputPortBuffer](../../src/bsv/Port.bsv#L125)
```bluespec
typeclass MkInputPortBuffer#(type in_t, type port_t);
    module mkInputPortBuffer#(in_t x)(InputPort#(port_t));
    module mkInputPortBypassBuffer#(in_t x)(InputPort#(port_t));
endtypeclass


```

### [MkOutputPortBuffer](../../src/bsv/Port.bsv#L130)
```bluespec
typeclass MkOutputPortBuffer#(type in_t, type port_t);
    module mkOutputPortBuffer#(in_t x)(OutputPort#(port_t));
    module mkOutputPortBypassBuffer#(in_t x)(OutputPort#(port_t));
endtypeclass


```

### [Connectable](../../src/bsv/Port.bsv#L136)
```bluespec
instance Connectable#(OutputPort#(t), InputPort#(t));
    module mkConnection#(OutputPort#(t) a, InputPort#(t) b)(Empty);
        rule connection;
            a.deq();
            b.enq(a.first);
        endrule
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L145)
```bluespec
instance Connectable#(InputPort#(t), OutputPort#(t));
    module mkConnection#(InputPort#(t) a, OutputPort#(t) b)(Empty);
        rule connection;
            b.deq();
            a.enq(b.first);
        endrule
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L154)
```bluespec
instance Connectable#(ServerPort#(req_t, resp_t), ClientPort#(req_t, resp_t));
    module mkConnection#(ServerPort#(req_t, resp_t) a, ClientPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L161)
```bluespec
instance Connectable#(ClientPort#(req_t, resp_t), ServerPort#(req_t, resp_t));
    module mkConnection#(ClientPort#(req_t, resp_t) a, ServerPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L169)
```bluespec
instance Connectable#(OutputPort#(t), Put#(t));
    module mkConnection#(OutputPort#(t) a, Put#(t) b)(Empty);
        rule connection;
            a.deq();
            b.put(a.first);
        endrule
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L178)
```bluespec
instance Connectable#(Put#(t), OutputPort#(t));
    module mkConnection#(Put#(t) a, OutputPort#(t) b)(Empty);
        rule connection;
            b.deq();
            a.put(b.first);
        endrule
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L188)
```bluespec
instance Connectable#(Get#(t), InputPort#(t));
    module mkConnection#(Get#(t) a, InputPort#(t) b)(Empty);
        rule connection;
            let val <- a.get();
            b.enq(val);
        endrule
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L197)
```bluespec
instance Connectable#(InputPort#(t), Get#(t));
    module mkConnection#(InputPort#(t) a, Get#(t) b)(Empty);
        rule connection;
            let val <- b.get();
            a.enq(val);
        endrule
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L207)
```bluespec
instance Connectable#(ServerPort#(req_t, resp_t), Client#(req_t, resp_t));
    module mkConnection#(ServerPort#(req_t, resp_t) a, Client#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L214)
```bluespec
instance Connectable#(Client#(req_t, resp_t), ServerPort#(req_t, resp_t));
    module mkConnection#(Client#(req_t, resp_t) a, ServerPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L222)
```bluespec
instance Connectable#(Server#(req_t, resp_t), ClientPort#(req_t, resp_t));
    module mkConnection#(Server#(req_t, resp_t) a, ClientPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### [Connectable](../../src/bsv/Port.bsv#L229)
```bluespec
instance Connectable#(ClientPort#(req_t, resp_t), Server#(req_t, resp_t));
    module mkConnection#(ClientPort#(req_t, resp_t) a, Server#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### [ToInputPort](../../src/bsv/Port.bsv#L236)
```bluespec
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


```

### [ToOutputPort](../../src/bsv/Port.bsv#L249)
```bluespec
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


```

### [MkInputPortBuffer](../../src/bsv/Port.bsv#L266)
```bluespec
instance MkInputPortBuffer#(in_t, port_t) provisos (ToInputPort#(in_t, port_t));
    module mkInputPortBuffer#(in_t x)(InputPort#(port_t));
        return toInputPort(x);
    endmodule
    module mkInputPortBypassBuffer#(in_t x)(InputPort#(port_t));
        return toInputPort(x);
    endmodule
endinstance


```

### [MkOutputPortBuffer](../../src/bsv/Port.bsv#L276)
```bluespec
instance MkOutputPortBuffer#(in_t, port_t) provisos (ToOutputPort#(in_t, port_t));
    module mkOutputPortBuffer#(in_t x)(OutputPort#(port_t));
        return toOutputPort(x);
    endmodule
    module mkOutputPortBypassBuffer#(in_t x)(OutputPort#(port_t));
        return toOutputPort(x);
    endmodule
endinstance


```

### [MkInputPortBuffer](../../src/bsv/Port.bsv#L285)
```bluespec
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


```

### [MkOutputPortBuffer](../../src/bsv/Port.bsv#L320)
```bluespec
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


```

### [ToServerPort](../../src/bsv/Port.bsv#L359)
```bluespec
typeclass ToServerPort#(type req_ifc_t, type resp_ifc_t, type req_t, type resp_t);
    function ServerPort#(req_t, resp_t) toServerPort(req_ifc_t req_ifc, resp_ifc_t resp_ifc);
endtypeclass


```

### [ToServerPort](../../src/bsv/Port.bsv#L363)
```bluespec
instance ToServerPort#(InputPort#(req_t), OutputPort#(resp_t), req_t, resp_t);
    function ServerPort#(req_t, resp_t) toServerPort(InputPort#(req_t) req_ifc, OutputPort#(resp_t) resp_ifc);
        return (interface ServerPort;
                    interface InputPort request = req_ifc;
                    interface OutputPort response = resp_ifc;
                endinterface);
    endfunction
endinstance


```

### [ToServerPort](../../src/bsv/Port.bsv#L372)
```bluespec
instance ToServerPort#(req_ifc_t, resp_ifc_t, req_t, resp_t) provisos (ToInputPort#(req_ifc_t, req_t), ToOutputPort#(resp_ifc_t, resp_t));
    function ServerPort#(req_t, resp_t) toServerPort(req_ifc_t req_ifc, resp_ifc_t resp_ifc);
        return (interface ServerPort;
                    interface InputPort request = toInputPort(req_ifc);
                    interface OutputPort response = toOutputPort(resp_ifc);
                endinterface);
    endfunction
endinstance


```

### [ToClientPort](../../src/bsv/Port.bsv#L381)
```bluespec
typeclass ToClientPort#(type req_ifc_t, type resp_ifc_t, type req_t, type resp_t);
    function ClientPort#(req_t, resp_t) toClientPort(req_ifc_t req_ifc, resp_ifc_t resp_ifc);
endtypeclass


```

### [ToClientPort](../../src/bsv/Port.bsv#L385)
```bluespec
instance ToClientPort#(OutputPort#(req_t), InputPort#(resp_t), req_t, resp_t);
    function ClientPort#(req_t, resp_t) toClientPort(OutputPort#(req_t) req_ifc, InputPort#(resp_t) resp_ifc);
        return (interface ClientPort;
                    interface OutputPort request = req_ifc;
                    interface InputPort response = resp_ifc;
                endinterface);
    endfunction
endinstance


```

### [ToClientPort](../../src/bsv/Port.bsv#L394)
```bluespec
instance ToClientPort#(req_ifc_t, resp_ifc_t, req_t, resp_t) provisos (ToOutputPort#(req_ifc_t, req_t), ToInputPort#(resp_ifc_t, resp_t));
    function ClientPort#(req_t, resp_t) toClientPort(req_ifc_t req_ifc, resp_ifc_t resp_ifc);
        return (interface ClientPort;
                    interface OutputPort request = toOutputPort(req_ifc);
                    interface InputPort response = toInputPort(resp_ifc);
                endinterface);
    endfunction
endinstance


```

