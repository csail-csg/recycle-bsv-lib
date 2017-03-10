## ['Ehr', ['numeric', 'type', 'n', 'type', 't']]
```bluespec
typedef Vector#(n, Reg#(t)) Ehr#(numeric type n, type t);
```

## readVEhr
```bluespec
function Vector#(n, t) readVEhr(i ehr_index, Vector#(n, Ehr#(n2, t)) vec_ehr) provisos (PrimIndex#(i, __a));
    function Reg#(t) get_ehr_index(Ehr#(n2, t) e) = e[ehr_index];
    return readVReg(map(get_ehr_index, vec_ehr));
endfunction


```

## writeVEhr
```bluespec
function Action writeVEhr(i ehr_index, Vector#(n, Ehr#(n2, t)) vec_ehr, Vector#(n, t) data) provisos (PrimIndex#(i, __a));
    function Reg#(t) get_ehr_index(Ehr#(n2, t) e) = e[ehr_index];
    return writeVReg(map(get_ehr_index, vec_ehr), data);
endfunction


```

## mkEhr
```bluespec
module mkEhr#(t initVal)(Ehr#(n, t)) provisos (Bits#(t, tSz));
    // mkUnsafeWire allows for combinational paths through the EHR within the
    // same rule. To prevent this behavior, use mkRWire instead.
    Vector#(n, RWire#(t)) port <- replicateM(mkUnsafeRWire);
    Reg#(t) register <- mkReg(initVal);

    // RevertingVirtualReg's to force the scheduling constraint
    // _read[i] < _write[j] for i < j.
    Vector#(n, Reg#(Bool)) readBeforeLaterWrites <- replicateM(mkRevertingVirtualReg(True));

    // Canonicalize rule to write the last written value to the internal
    // register. These attributes are statically checked by the compiler.
    (* fire_when_enabled *)         // WILL_FIRE == CAN_FIRE
    (* no_implicit_conditions *)    // CAN_FIRE == guard (True)
    rule canonicalize;
        t nextVal = register;
        for (Integer i = 0 ; i < valueOf(n) ; i = i+1) begin
            nextVal = fromMaybe(nextVal, port[i].wget);
        end
        register <= nextVal;
    endrule

    // Vector of interfaces that will be built up and returned.
    Ehr#(n, t) _m = newVector;
    for(Integer i = 0; i < valueOf(n); i = i + 1) begin
        _m[i] = (interface Reg;
                    method Action _write(t x);
                        // currentVal is computed to force the ordering w[i] < w[j]
                        t currentVal = register;
                        for (Integer j = 0 ; j < i ; j = j+1) begin
                            currentVal = fromMaybe(currentVal, port[j].wget);
                        end

                        // Writing to readBeforeLaterWrites prevents earlier
                        // reads from happing after this write.
                        readBeforeLaterWrites[i] <= False;

                        port[i].wset(readBeforeLaterWrites[i] ? x : currentVal);
                    endmethod

                    method t _read;
                        // Compute the current value for this port
                        t currentVal = register;
                        for (Integer j = 0 ; j < i ; j = j+1) begin
                            currentVal = fromMaybe(currentVal, port[j].wget);
                        end

                        // Reading from readBeforeLaterWrites prevents this
                        // read from happening after later writes.
                        Bool genConstraints = True;
                        for (Integer j = i ; j < valueOf(n) ; j = j+1) begin
                            genConstraints = genConstraints && readBeforeLaterWrites[j];
                        end

                        return genConstraints ? currentVal : ?;
                    endmethod
                endinterface);
    end
    return _m;
endmodule


```

## mkEhrU
```bluespec
module mkEhrU(Ehr#(n, t)) provisos (Bits#(t, tSz));
    (* hide *)
    Ehr#(n, t) _m <- mkEhr(?);
    return _m;
endmodule


```

