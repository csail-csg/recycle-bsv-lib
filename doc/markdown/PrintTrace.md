# PrintTrace

### HasTypeIsVoid
```bluespec
typeclass HasTypeIsVoid#(type t);
    function Bool typeIsVoid(t x);
        return False;
    endfunction
endtypeclass

```

### HasTypeIsVoid
```bluespec
instance HasTypeIsVoid#(void);
    function Bool typeIsVoid(void x);
        return True;
    endfunction
endinstance


```

### HasFPrintTraceHelper
```bluespec
typeclass HasFPrintTraceHelper#(type t);
    function t fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, t x);
endtypeclass

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(ActionValue#(t)) provisos (FShow#(t));
    function ActionValue#(t) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, ActionValue#(t) av);
        return (actionvalue
                t x <- av;
                Fmt printFmt = callName;
                if (args matches tagged Valid .validArgs) begin
                    printFmt = printFmt + $format("(", validArgs, ")");
                end
                // if (t != void)
                void v = ?;
                if (typeOf(x) != typeOf(v)) begin
                    printFmt = printFmt + $format(" = ", fshow(x));
                end
                if (printTimestamp) begin 
                   $fdisplay(file, "(%0d) ", $time, printFmt);
                end
                else begin
                   $fdisplay(file, printFmt);
                end
                $fflush(file);
                return x;
            endactionvalue);
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(function outT f(inT x)) provisos (HasFPrintTraceHelper#(outT), FShow#(inT));
    function (function outT f(inT x)) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, function outT func(inT x));
        function outT retFunc(inT x);
            Fmt newArgs = args matches tagged Valid .validArgs ? validArgs + $format(", ") + fshow(x) : fshow(x);
            return fprintTraceHelper(file, printTimestamp, callName, tagged Valid newArgs, func(x));
        endfunction
        return retFunc;
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(Reg#(t)) provisos (FShow#(t));
    function Reg#(t) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, Reg#(t) ifc);
        // if there were arguments, add it to the callName
        Fmt newCallName = args matches tagged Valid .validArgs ? $format(callName, "(", validArgs, ")") : callName;
        Maybe#(Fmt) newArgs = tagged Invalid;
        return (interface Reg;
                    method Action _write(t x) = fprintTraceHelper(file, printTimestamp, $format(newCallName, "._write"), newArgs, ifc._write, x);
                    method t _read = ifc._read;
                endinterface);
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(Get#(t)) provisos (FShow#(t));
    function Get#(t) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, Get#(t) ifc);
        // if there were arguments, add it to the callName
        Fmt newCallName = args matches tagged Valid .validArgs ? $format(callName, "(", validArgs, ")") : callName;
        Maybe#(Fmt) newArgs = tagged Invalid;
        return toGet(fprintTraceHelper(file, printTimestamp, $format(newCallName, ".get"), newArgs, ifc.get));
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(Put#(t)) provisos (FShow#(t));
    function Put#(t) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, Put#(t) ifc);
        // if there were arguments, add it to the callName
        Fmt newCallName = args matches tagged Valid .validArgs ? $format(callName, "(", validArgs, ")") : callName;
        Maybe#(Fmt) newArgs = tagged Invalid;
        return toPut(fprintTraceHelper(file, printTimestamp, $format(newCallName, ".put"), newArgs, ifc.put));
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(Client#(t1,t2)) provisos (FShow#(t1), FShow#(t2));
    function Client#(t1,t2) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, Client#(t1,t2) ifc);
        // if there were arguments, add it to the callName
        Fmt newCallName = args matches tagged Valid .validArgs ? $format(callName, "(", validArgs, ")") : callName;
        Maybe#(Fmt) newArgs = tagged Invalid;
        return toGPClient(fprintTraceHelper(file, printTimestamp, $format(newCallName, ".request"), newArgs, ifc.request),
                          fprintTraceHelper(file, printTimestamp, $format(newCallName, ".response"), newArgs, ifc.response));
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(Server#(t1,t2)) provisos (FShow#(t1), FShow#(t2));
    function Server#(t1,t2) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, Server#(t1,t2) ifc);
        // if there were arguments, add it to the callName
        Fmt newCallName = args matches tagged Valid .validArgs ? $format(callName, "(", validArgs, ")") : callName;
        Maybe#(Fmt) newArgs = tagged Invalid;
        return toGPServer(fprintTraceHelper(file, printTimestamp, $format(newCallName, ".request"), newArgs, ifc.request),
                          fprintTraceHelper(file, printTimestamp, $format(newCallName, ".response"), newArgs, ifc.response));
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(FIFO#(t)) provisos (FShow#(t));
    function FIFO#(t) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, FIFO#(t) ifc);
        // if there were arguments, add it to the callName
        Fmt newCallName = args matches tagged Valid .validArgs ? $format(callName, "(", validArgs, ")") : callName;
        Maybe#(Fmt) newArgs = tagged Invalid;
        return (interface FIFO;
                    method Action enq(t x); fprintTraceHelper(file, printTimestamp, $format(newCallName, ".enq"), newArgs, ifc.enq, x); endmethod
                    // when printing, make deq look like an action value so you can see the value of first
                    method Action deq = fprintTraceHelper(file, printTimestamp, $format(newCallName, ".deq = ", fshow(ifc.first)), newArgs, ifc.deq);
                    method t first = ifc.first;
                    method Action clear = fprintTraceHelper(file, printTimestamp, $format(newCallName, ".clear"), newArgs, ifc.clear);
                endinterface);
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(FIFOF#(t)) provisos (FShow#(t));
    function FIFOF#(t) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, FIFOF#(t) ifc);
        // if there were arguments, add it to the callName
        Fmt newCallName = args matches tagged Valid .validArgs ? $format(callName, "(", validArgs, ")") : callName;
        Maybe#(Fmt) newArgs = tagged Invalid;
        return (interface FIFOF;
                    method Action enq(t x) = fprintTraceHelper(file, printTimestamp, $format(newCallName, ".enq"), newArgs, ifc.enq, x);
                    // when printing, make deq look like an action value so you can see the value of first
                    method Action deq = fprintTraceHelper(file, printTimestamp, $format(newCallName, ".deq = ", fshow(ifc.first)), newArgs, ifc.deq);
                    method t first = ifc.first;
                    method Bool notFull = ifc.notFull;
                    method Bool notEmpty = ifc.notEmpty;
                    method Action clear = fprintTraceHelper(file, printTimestamp, $format(newCallName, ".clear"), newArgs, ifc.clear);
                endinterface);
    endfunction
endinstance

```

### HasFPrintTraceHelper
```bluespec
instance HasFPrintTraceHelper#(Vector#(n,t)) provisos (HasFPrintTraceHelper#(t));
    function Vector#(n,t) fprintTraceHelper(File file, Bool printTimestamp, Fmt callName, Maybe#(Fmt) args, Vector#(n,t) ifc);
        // if there were arguments, add it to the callName
        Fmt newCallName = args matches tagged Valid .validArgs ? $format(callName, "(", validArgs, ")") : callName;
        Maybe#(Fmt) newArgs = tagged Invalid;

        function t genFunc(Integer i);
            return fprintTraceHelper(file, printTimestamp, $format(callName, "[%d]", i), tagged Invalid, ifc[i]);
        endfunction
        return genWith(genFunc);
    endfunction
endinstance


```

### fprintTrace


This function takes in an object `x` of type `t` and returns a version of
that object which prints trace messages to `file` when something happens to
it.

This is a polymoriphic function, so the exact behavior depends on the type
`t`.

If `t` is `Put` or `Get`, a message is printed each time the interface is
used. If `t` is `FIFO`, a message is printed on each enqueue and dequeue.

The printed message starts with the string `msg`.

```bluespec
function t fprintTrace(File file, String msg, t x)
        provisos (HasFPrintTraceHelper#(t));
    return fprintTraceHelper(file, False, $format(msg), tagged Invalid, x);
endfunction


```

### printTrace
```bluespec
function t printTrace(String msg, t x)
        provisos (HasFPrintTraceHelper#(t));
    return fprintTraceHelper(stdout, False, $format(msg), tagged Invalid, x);
endfunction


```

### fprintTraceM
```bluespec
module [m] fprintTraceM#(File file, String msg, m#(t) mkM)(t)
        provisos (IsModule#(m, a__), HasFPrintTraceHelper#(t));
    (* hide *)
    t _m <- mkM();
    return fprintTraceHelper(file, False, $format(msg), tagged Invalid, _m);
endmodule


```

### printTraceM
```bluespec
module [m] printTraceM#(String msg, m#(t) mkM)(t)
        provisos (IsModule#(m, a__), HasFPrintTraceHelper#(t));
    (* hide *)
    t _m <- mkM;
    return fprintTraceHelper(stdout, False, $format(msg), tagged Invalid, _m);
endmodule


```

### printTimedTraceM
```bluespec
module [m] printTimedTraceM#(String msg, m#(t) mkM)(t)
        provisos (IsModule#(m, a__), HasFPrintTraceHelper#(t));
    (* hide *)
    t _m <- mkM;
    return fprintTraceHelper(stdout, True, $format(msg), tagged Invalid, _m);
endmodule


```

