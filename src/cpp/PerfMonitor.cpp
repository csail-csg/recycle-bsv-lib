
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

#include <iostream>
#include <fstream>
#include <streambuf>
#include <sstream>

#include "PerfMonitor.hpp"

PerfMonitor::PerfMonitor(unsigned int indicationId, unsigned int requestId) :
        PerfMonitorIndicationWrapper(indicationId) {
    performanceRequest = new PerfMonitorRequestProxy(requestId);
    sem_init(&respSem, 0, 0);
}

void PerfMonitor::printPerformance(std::string filename) {
    std::ifstream file(filename);
    std::string line;
    std::string name;
    uint32_t index;

    while (std::getline(file, line)) {
        size_t commaIndex = line.find(','); 
        if (commaIndex != std::string::npos) {
            if (line.substr(0,2) == "0x") {
                std::istringstream s(line.substr(2, commaIndex));
                s >> std::hex >> index;
            } else {
                std::istringstream s(line.substr(0, commaIndex));
                s >> index;
            }
            name = line.substr(commaIndex+1);
            std::cout << name << " = " << readMonitor(index) << std::endl;
        }
    }
}

void PerfMonitor::setEnable(const int x) {
    performanceRequest->setEnable(x);
}

uint64_t PerfMonitor::readMonitor(const uint32_t index) {
    performanceRequest->req((uint64_t) index);
    // set semaphore
    sem_wait(&respSem);
    uint64_t resp = prevResp;
    return resp;
}

void PerfMonitor::resp(const uint64_t x) {
    prevResp = x;
    sem_post(&respSem);
}
