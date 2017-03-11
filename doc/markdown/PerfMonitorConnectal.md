# PerfMonitorConnectal


PerfMonitor interfaces for connectal


### [PerfMonitorRequest](../../src/bsv/PerfMonitorConnectal.bsv#L30)
```bluespec
interface PerfMonitorRequest;
    method Action reset;
    method Action setEnable(Bool en);
    method Action req(Bit#(32) index); // XXX: assumes PerfIndex == Bit#(32)
endinterface


```

### [PerfMonitorIndication](../../src/bsv/PerfMonitorConnectal.bsv#L36)
```bluespec
interface PerfMonitorIndication;
    method Action resp(Bit#(64) x); // XXX: assumes PerfData == Bit#(64)
endinterface


```

