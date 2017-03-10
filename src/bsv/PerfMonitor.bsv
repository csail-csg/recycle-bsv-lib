
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
 * This package contains the necessary modules to attach a PerfMonitor
 * (short for Performance Monitor) to a design.
 *
 * TODO: explain what makes a PerfMonitor (i.e. PerfCounters and monadic
 * computation)
 */
package PerfMonitor;

import ConfigReg::*;
import FIFO::*;
import List::*;
import ModuleContext::*;
import Printf::*;
import StmtFSM::*;
import StringUtils::*;

// export everything in this file
// TODO: export connectal interface from PerfMonitorConnectal.bsv and check
// some type assertions if possible.

/// PerfCounter interface exposed within modules under performance monitoring
interface PerfCounter;
    method Action increment(PerfData x);
    method Action set(PerfData x);
endinterface

/// PerfMonitor interface exposed to the outside
interface PerfMonitor;
    method Action reset;
    method Action setEnable(Bool en);
    method Action req(PerfIndex index);
    method ActionValue#(PerfData) resp;
endinterface

// PerfMonitorRequest/Indication interfaces for connectal
//interface PerfMonitorRequest;
//    method Action reset;
//    method Action setEnable(Bool en);
//    method Action req(Bit#(32) index); // XXX: assumes PerfIndex == Bit#(32)
//endinterface
//interface PerfMonitorIndication;
//    method Action resp(Bit#(64) x); // XXX: assumes PerfData == Bit#(64)
//endinterface

// Typedefs used primarily inside the PerfCounters and PerfMonitor
typedef 64 PerfDataSz;
typedef 8 PerfSubIndexSz;
typedef 4 PerfLevels;
typedef TMul#(PerfSubIndexSz, PerfLevels) PerfIndexSz;

typedef Bit#(PerfDataSz) PerfData;
typedef Bit#(PerfSubIndexSz) PerfSubIndex;
typedef Bit#(PerfIndexSz) PerfIndex;

// File extension for Performance Monitor configuration files
String perfMonitorExt = ".perfmon.txt";

/// structure for tracking a single counter
typedef struct {
    Reg#(PerfData) counter;
    String         name;
} PerfCounterInfo;

/// structure for tracking a submodule
typedef struct {
    PerfMonitor submodule;
    String      name;
} PerfSubmoduleInfo;

/// keeps track of perf counters in this module and in submodules
typedef struct {
    Reg#(Bool)               enReg;
    List#(PerfCounterInfo)   counters;
    List#(PerfSubmoduleInfo) submodules;
} PerfContext;

/// module type for a module that contains perf counters
typedef ModuleContext#(PerfContext) PerfModule;

/// provisos shortcut for IsModule#(m, a__) and Context#(m, PerfContext)
typeclass HasPerfCounters#(type m);
endtypeclass
instance HasPerfCounters#(m) provisos (IsModule#(m, a__), Context#(m, PerfContext));
endinstance

module [m] mkPerfCounter#(String name)(PerfCounter) provisos(HasPerfCounters#(m));
    Reg#(PerfData) count <- mkConfigReg(0);

    PerfContext currentContext <- getContext;
    Bool en = currentContext.enReg;
    PerfCounterInfo perfCounterInfo = PerfCounterInfo{counter: asReg(count), name: name};
    currentContext.counters = List::cons(perfCounterInfo, currentContext.counters);
    putContext(currentContext);

    method Action increment(PerfData x);
        if (en) begin
            count <= count + x;
        end
    endmethod
    method Action set(PerfData x);
        if (en) begin
            count <= x;
        end
    endmethod
endmodule

module [Module] mkPerfMonitor#(PerfContext perfContext, String filename)(PerfMonitor);
    FIFO#(PerfData) respFifo <- mkFIFO;

    // get the counters and submodules list in instantiation order
    let counters = reverse(perfContext.counters);
    let submodules = reverse(perfContext.submodules);

    // enumerate the counters and submodules
    let numCounters = List::length(counters); // [0 ... numCounters-1]
    let numSubmodules = List::length(submodules); // [numCounters ... numCounters+numSubmodules-1]

    // ensure that numCounters + numSubmodules is less than 
    if (numCounters + numSubmodules > valueOf(TExp#(PerfSubIndexSz))) begin
        // This is an error
        errorM("PerfSubIndexSz is not large index all the perf counters");
    end

    // open a textfile for output
    Handle fp <- openFile(filename + perfMonitorExt, WriteMode);
    // initialize lists to count duplicate names ...
    List#(String) allCounterNames = tagged Nil;
    List#(String) allSubmoduleNames = tagged Nil;
    // ... and create a function for counting duplicate names
    function Integer countDuplicates(List#(String) allNames, String name);
        return length(filter( \== (name), allNames ));
    endfunction
    for (Integer i = 0 ; i < numCounters + numSubmodules ; i = i+1) begin
        if (i < numCounters) begin
            // uniquify counterName
            String counterName = counters[i].name;
            let duplicates = countDuplicates(allCounterNames, counterName);
            allCounterNames = List::cons(counterName, allCounterNames);
            if (duplicates != 0) begin
                counterName = counterName + "_" + integerToString(duplicates+1);
            end
            // write index and counter name to text file
            hPutStrLn(fp, sprintf("0x%0x,%s", i, counterName));
        end else begin
            // uniquify submoduleName
            String submoduleName = submodules[i-numCounters].name;
            let duplicates = countDuplicates(allSubmoduleNames, submoduleName);
            allSubmoduleNames = List::cons(submoduleName, allSubmoduleNames);
            if (duplicates != 0) begin
                submoduleName = submoduleName + "_" + integerToString(duplicates+1);
            end
            // write submodule information to textfile
            Handle smfp <- openFile(submodules[i-numCounters].name + perfMonitorExt, ReadMode);
            let readable <- hIsReadable(smfp);
            if (readable) begin
                // the submodule file has been opened for reading
                Bool isEOF <- hIsEOF(smfp);
                while (!isEOF) begin
                    let line <- hGetLine(smfp);
                    let {counterIndexString, counterNameString} = splitStringAtComma(line);
                    let counterIndex = (hexStringToInteger(counterIndexString) * valueOf(TExp#(PerfSubIndexSz))) + i;
                    let counterName = submoduleName + "::" + counterNameString;
                    hPutStrLn(fp, sprintf("0x%0x,%s", counterIndex, counterName));
                    isEOF <- hIsEOF(smfp);
                end
            end else begin
                // XXX: This should probably just be an error
                // couldn't read into the submodule
                hPutStrLn(fp, sprintf("0x%0x,%s", i, submoduleName));
            end
            hClose(smfp);
        end
    end
    hClose(fp);

    for (Integer i = 0 ; i < numSubmodules ; i = i+1) begin
        rule gatherResp;
            let x <- submodules[i].submodule.resp;
            respFifo.enq(x);
        endrule
    end

    method Action reset;
        // write 0 to all the current counters
        for (Integer i = 0 ; i < numCounters ; i = i+1) begin
            counters[i].counter <= 0;
        end
        // reset all the submodule counters
        for (Integer i = 0 ; i < numSubmodules ; i = i+1) begin
            submodules[i].submodule.reset;
        end
    endmethod
    method Action setEnable(Bool en);
        // write en to the enable register for the current counters
        perfContext.enReg <= en;
        // set the enable for all submodules
        for (Integer i = 0 ; i < numSubmodules ; i = i+1) begin
            submodules[i].submodule.setEnable(en);
        end
    endmethod
    method Action req(PerfIndex index);
        // the least significant bits of the index are for the current modules
        PerfSubIndex currPerfIndex = truncate(index);
        // the upper bits are for the submodules
        PerfIndex submodulePerfIndex = index >> valueOf(PerfSubIndexSz);

        Bool isCounterIndex = currPerfIndex < fromInteger(numCounters);
        Bool isSubmoduleIndex = !isCounterIndex && (currPerfIndex < fromInteger(numCounters + numSubmodules));


        if (isCounterIndex && (submodulePerfIndex == 0)) begin
            // this index corresponds to a counter in the current module
            respFifo.enq(counters[currPerfIndex].counter);
        end else if (isSubmoduleIndex) begin
            submodules[currPerfIndex - fromInteger(numCounters)].submodule.req(submodulePerfIndex);
        end else begin
            // either it is neither a counter index nor a submodule index, or
            // it is a counter index with a non-zero submodulePerfIndex.
            respFifo.enq('1);
        end
    endmethod
    method ActionValue#(PerfData) resp;
        respFifo.deq;
        return respFifo.first;
    endmethod
endmodule

module mkInitialPerfContext(PerfContext);
    Reg#(Bool) enReg <- mkConfigReg(True);
    PerfContext initialCompleteContext = PerfContext{enReg: asReg(enReg), counters: tagged Nil, submodules: tagged Nil};
    return initialCompleteContext;
endmodule

module [Module] toSynthBoundary#(String name, PerfModule#(ifcType) mkModuleDef)(Tuple2#(PerfMonitor, ifcType));
    let initialContext <- mkInitialPerfContext;
    Tuple2#(PerfContext, ifcType) m <- runWithContext(initialContext, mkModuleDef);
    let finalContext = tpl_1(m);
    let moduleIfc = tpl_2(m);
    let perfMonitorIfc <- mkPerfMonitor(finalContext, name);
    return tuple2(perfMonitorIfc, moduleIfc);
endmodule

module [m] fromSynthBoundary#(String name, Module#(Tuple2#(PerfMonitor, ifcType)) mkModuleSynth)(ifcType) provisos(IsModule#(m, a__), Context#(m, PerfContext));
    Tuple2#(PerfMonitor, ifcType) combinedIfc <- liftModule(mkModuleSynth);
    let perfMonitorIfc = tpl_1(combinedIfc);
    let moduleIfc = tpl_2(combinedIfc);
    PerfContext currentContext <- getContext;
    PerfSubmoduleInfo perfSubmoduleInfo = PerfSubmoduleInfo{submodule: perfMonitorIfc, name: name};
    currentContext.submodules = List::cons(perfSubmoduleInfo, currentContext.submodules);
    putContext(currentContext);
    return moduleIfc;
endmodule

// (*synthesize*)
// module [Module] mkMV(Tuple2#(CompleteContextIfc,IM));
//    let init <- mkInitialCompleteContext;
//    let _ifc <- unbury(init, mkM0);
//    return _ifc;
// endmodule
// 
// module [ModuleContext#(CompleteContext)] mkM(IM);
//    let _ifc <- rebury(mkMV);
//    return _ifc;
// endmodule
module mkPerfOutputFSM#(String topModuleName, PerfMonitor perfMonitor)(FSM);
    // TODO: make this depend on the length of perfCounterList
    Reg#(Bit#(8)) fsmIndex <- mkReg(0);

    List#(Tuple2#(String, PerfIndex)) perfCounterList = tagged Nil;

    // do processing on the file
    String filename = topModuleName + perfMonitorExt;
    Handle fp <- openFile(filename, ReadMode);
    let readable <- hIsReadable(fp);
    if (!readable) begin
        errorM("Can't open file " + doubleQuote(filename));
    end
    Bool isEOF <- hIsEOF(fp);
    while (!isEOF) begin
        let line <- hGetLine(fp);
        // indexList and nameList will be built up in reverse order
        List#(Integer) indexList = tagged Nil;
        List#(String) nameList = tagged Nil;
        // parse the line and add indexes and names to the corresponding lists
        List#(String) parsedEntries = parseCSV(line);
        while (parsedEntries != tagged Nil) begin
            indexList = List::cons(hexStringToInteger(parsedEntries[0]), indexList);
            nameList = List::cons(parsedEntries[1], nameList);
            parsedEntries = drop(2, parsedEntries);
        end
        // produce a single name and index for the entry
        function String nameFold(String x, String y);
            return x + "::" + y;
        endfunction
        String perfCounterName = foldl1(nameFold, reverse(nameList));
        function Integer indexFold(Integer x, Integer y);
            return (x * valueOf(TExp#(PerfSubIndexSz))) + y;
        endfunction
        PerfIndex perfCounterIndex = fromInteger(foldl1(indexFold, indexList));
        // add the name and index to perfCoutnerList
        perfCounterList = List::cons(tuple2(perfCounterName, perfCounterIndex), perfCounterList);

        isEOF <- hIsEOF(fp);
    end
    hClose(fp);
    perfCounterList = reverse(perfCounterList);

    // sanity check for size of fsmIndex
    if (length(perfCounterList) >= 255) begin
        errorM("perfCounterList is too large for a Bit#(8) fsmIndex");
    end

    Stmt fsm =
        (seq
            fsmIndex <= 0;
            while (fsmIndex < fromInteger(length(perfCounterList))) seq
                perfMonitor.req(tpl_2(perfCounterList[fsmIndex]));
                action
                    let x <- perfMonitor.resp;
                    $display("0x%0x, %s = %0d", tpl_2(perfCounterList[fsmIndex]), tpl_1(perfCounterList[fsmIndex]), x);
                endaction
                fsmIndex <= fsmIndex + 1;
            endseq
        endseq);
    (* hide *)
    let _m <- mkFSM(fsm);
    return _m;
endmodule

endpackage
