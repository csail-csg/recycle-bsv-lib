
# Copyright (c) 2016 Massachusetts Institute of Technology

# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation
# files (the "Software"), to deal in the Software without
# restriction, including without limitation the rights to use, copy,
# modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# This makefile just builds bo files for each bsv file in bsv/src. This is
# primarily used by Travis CI for testing

BSV_SRC_DIR ?= src/bsv
BUILD_DIR ?= build
DOC_DIR ?= doc
BSV_FILES = $(wildcard $(BSV_SRC_DIR)/*.bsv)
BO_FILES = $(patsubst $(BSV_SRC_DIR)/%.bsv, $(BSV_BUILD_DIR)/%.bo, $(BSV_FILES))

DOC_FILES = $(patsubst $(BSV_SRC_DIR)/%.bsv, $(DOC_DIR)/markdown/%.md, $(BSV_FILES))

.PHONY: all build doc

all: build doc

build: $(BO_FILES)

doc: $(DOC_FILES)

$(BSV_BUILD_DIR)/%.bo: $(BSV_SRC_DIR)/%.bsv
	@mkdir -p $(BUILD_DIR)
	bsc -u -p $(BSV_SRC_DIR):+ -bdir $(BUILD_DIR) $^

$(DOC_DIR)/markdown/%.md: $(BSV_SRC_DIR)/%.bsv src/py/bsv_doc_gen.py
	@mkdir -p $(DOC_DIR)/markdown
	./src/py/bsv_doc_gen.py $^ > $@

clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(DOC_DIR)
