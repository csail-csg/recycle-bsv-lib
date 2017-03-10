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


### ToInputPort
```bluespec
typeclass ToInputPort#(type in_t, type port_t);
    function InputPort#(port_t) toInputPort(in_t x);
endtypeclass


```

### ToOutputPort
```bluespec
typeclass ToOutputPort#(type in_t, type port_t);
    function OutputPort#(port_t) toOutputPort(in_t x);
endtypeclass


```

### MkInputPortBuffer
```bluespec
typeclass MkInputPortBuffer#(type in_t, type port_t);
    module mkInputPortBuffer#(in_t x)(InputPort#(port_t));
    module mkInputPortBypassBuffer#(in_t x)(InputPort#(port_t));
endtypeclass


```

### MkOutputPortBuffer
```bluespec
typeclass MkOutputPortBuffer#(type in_t, type port_t);
    module mkOutputPortBuffer#(in_t x)(OutputPort#(port_t));
    module mkOutputPortBypassBuffer#(in_t x)(OutputPort#(port_t));
endtypeclass


```

### Connectable
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

### Connectable
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

### Connectable
```bluespec
instance Connectable#(ServerPort#(req_t, resp_t), ClientPort#(req_t, resp_t));
    module mkConnection#(ServerPort#(req_t, resp_t) a, ClientPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### Connectable
```bluespec
instance Connectable#(ClientPort#(req_t, resp_t), ServerPort#(req_t, resp_t));
    module mkConnection#(ClientPort#(req_t, resp_t) a, ServerPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### Connectable
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

### Connectable
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

### Connectable
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

### Connectable
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

### Connectable
```bluespec
instance Connectable#(ServerPort#(req_t, resp_t), Client#(req_t, resp_t));
    module mkConnection#(ServerPort#(req_t, resp_t) a, Client#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### Connectable
```bluespec
instance Connectable#(Client#(req_t, resp_t), ServerPort#(req_t, resp_t));
    module mkConnection#(Client#(req_t, resp_t) a, ServerPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### Connectable
```bluespec
instance Connectable#(Server#(req_t, resp_t), ClientPort#(req_t, resp_t));
    module mkConnection#(Server#(req_t, resp_t) a, ClientPort#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### Connectable
```bluespec
instance Connectable#(ClientPort#(req_t, resp_t), Server#(req_t, resp_t));
    module mkConnection#(ClientPort#(req_t, resp_t) a, Server#(req_t, resp_t) b)(Empty);
        mkConnection(a.request, b.request);
        mkConnection(a.response, b.response);
    endmodule
endinstance


```

### ToInputPort
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

### ToOutputPort
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

### MkInputPortBuffer
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

### MkOutputPortBuffer
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

### MkInputPortBuffer
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

### MkOutputPortBuffer
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

