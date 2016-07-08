
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

#ifndef PERFORMANCE_HPP
#define PERFORMANCE_HPP

#include <semaphore.h>
#include <string>
#include "PerfMonitorIndication.h"
#include "PerfMonitorRequest.h"
#include "GeneratedTypes.h"

class PerfMonitor : public PerfMonitorIndicationWrapper {
    public:
        PerfMonitor(unsigned int indicationId, unsigned int requestId);
        ~PerfMonitor();

        // these are called by the main thread
        void printPerformance(std::string filename);
        void setEnable(const int x);
        uint64_t readMonitor(const uint32_t index);

        // theses are called by the PerformanceIndication thread
        void resp(const uint64_t x);

    private:
        PerfMonitorRequestProxy *performanceRequest;

        // used by both threads
        sem_t respSem;
        uint64_t prevResp;

        bool verbose;
};

#endif
