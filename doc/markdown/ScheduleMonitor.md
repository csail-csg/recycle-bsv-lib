# ScheduleMonitor

### [ScheduleMonitor](../../src/bsv/ScheduleMonitor.bsv#L28)
```bluespec
interface ScheduleMonitor;
    method Action record(String ruleName, Char char);
endinterface


```

### [mkScheduleMonitor](../../src/bsv/ScheduleMonitor.bsv#L32)
```bluespec
module mkScheduleMonitor#(File file, Vector#(n, String) ruleNames)(ScheduleMonitor);
    function Bit#(8) charToBits(Char c);
        return fromInteger(charToInteger(c));
    endfunction

    Reg#(Bool) init <- mkReg(False);
    Vector#(n, Reg#(Bit#(8))) schedWires <- replicateM(mkDWire(charToBits("_")));

    rule printLegend(!init);
        for (Integer i = 0 ; i < valueOf(n) ; i = i+1) begin
            for (Integer j = 0 ; j < i ; j = j+1) begin
                $fwrite(file, " ");
            end
            $fdisplay(file, ruleNames[i]);
        end
        init <= True;
    endrule

    rule printSchedule(init);
        for (Integer i = 0 ; i < valueOf(n) ; i = i+1) begin
            $fwrite(file, "%c", schedWires[i]);
        end
        $fdisplay(file, "");
    endrule

    method Action record(String ruleName, Char char);
        if (findElem(ruleName, ruleNames) matches tagged Valid .index) begin
            schedWires[index] <= charToBits(char);
        end else begin
            $fdisplay(stderr, "ERROR: schedule monitor can't find rule named: %s", ruleName);
        end
    endmethod
endmodule


```

