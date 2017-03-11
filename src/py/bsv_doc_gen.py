#!/usr/bin/env python3

# Copyright (c) 2017 Massachusetts Institute of Technology

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

import sys
import re
import pyparsing as pp

# pp.ParserElement.setDefaultWhitespaceChars(' \t')

# Testing infrastructure
tests = []
def add_tests(term, matches, no_matches):
    global tests
    tests += [(term, matches, no_matches)]
def run_tests():
    global tests
    errors = 0
    for (term, pass_examples, fail_examples) in tests:
        for string in pass_examples:
            try:
                result = term.parseString(string, parseAll = True)
                print(string + ' -> ' + str(result))
            except:
                print('ERROR: ' + string + ' -> no match')
                errors += 1
        for string in fail_examples:
            try:
                result = term.parseString(string, parseAll = True)
                print('ERROR: ' + string + ' -> ' + str(result))
                errors += 1
            except:
                print(string + ' -> no match')
    return errors

# BSV objects
def parse_type(toks):
    # print('type = ' + str(toks.asDict()))
    # return [''.join(toks)]
    return toks
    

    

# BSV comments
doc_comment=''
def collect_doc(toks):
    global doc_comment
    block = ''.join(toks)
    # block is entire comment block. Process it as necessary
    block = re.sub(r'\ */// ?', '', block)
    block = re.sub(r'\ */\** ?', '', block)
    block = re.sub(r'\ *\* ?', '', block)
    ### print(block)
    doc_comment += '\n' + block
def clear_doc():
    global doc_comment
    doc_comment = ''
doc_block_comment_bsv = (~pp.Literal('/**/') + pp.Regex(r"/\*\*([^*]*\*+)+?/")).setName('doc block comment').setParseAction(collect_doc)
doc_oneline_comment_bsv = ((pp.Literal('///') + pp.LineEnd()) | pp.Regex(r"///(\\\n|[^/])(\\\n|.)*")).setName('doc one line comment').setParseAction(collect_doc)
block_comment_bsv = (~doc_block_comment_bsv + pp.Regex(r"/\*(?:[^*]*\*+)+?/")).setName('block comment').setParseAction(clear_doc)
oneline_comment_bsv = (~doc_oneline_comment_bsv + pp.Regex(r"//(?:\\\n|.)*")).setName('one line comment').setParseAction(clear_doc)
comment_bsv = doc_block_comment_bsv | doc_oneline_comment_bsv | block_comment_bsv | oneline_comment_bsv

add_tests(oneline_comment_bsv, ['//', '//Hello, World!', '// Hello, World!', '////Hello, World!', '//// Hello, World!'], ['///', '///Hello, World!', '/// Hello, World!'])
add_tests(doc_oneline_comment_bsv, ['///', '///Hello, World!', '/// Hello, World!'], ['//', '//Hello, World!', '// Hello, World!', '////Hello, World!', '//// Hello, World!'])

# basic identifiers and literals
Identifier_bsv = pp.Word(pp.srange('[A-Z]'), pp.srange('[a-zA-Z0-9$_]'))
identifier_bsv = pp.Word(pp.srange('[a-z_]'), pp.srange('[a-zA-Z0-9$_]'))
anyIdentifier_bsv = pp.Word(pp.srange('[a-zA-Z_]'), pp.srange('[a-zA-Z0-9$_]'))
dec_literal_bsv = pp.Optional(pp.Optional(pp.Word(pp.nums)) + '\'' + pp.CaselessLiteral('d')) + pp.Word(pp.srange('[0-9_]'))
hex_literal_bsv = pp.Optional(pp.Word(pp.nums)) + '\'' + pp.CaselessLiteral('h') + pp.Word(pp.srange('[0-9A-Fa-f_]'))
oct_literal_bsv = pp.Optional(pp.Word(pp.nums)) + '\'' + pp.CaselessLiteral('o') + pp.Word(pp.srange('[0-7_]'))
bin_literal_bsv = pp.Optional(pp.Word(pp.nums)) + '\'' + pp.CaselessLiteral('b') + pp.Word(pp.srange('[01_]'))
int_literal_bsv = hex_literal_bsv | oct_literal_bsv | bin_literal_bsv | dec_literal_bsv | '\'0' | '\'1'

# some tests
add_tests(Identifier_bsv, ['Hello', 'World', 'A', 'ALL_CAPS', 'About_$3_50'], ['$display', 'a', '_TEST', '`Riscv', ''])
add_tests(identifier_bsv, ['hello', 'world', 'a', 'aLMOST_ALL_CAPS', 'about_$3_50', '_TEST_', '_abc'], ['$display', 'A', '`Riscv', ''])
add_tests(anyIdentifier_bsv, ['hello', 'Hello', 'HELLO', 'world'], [''])
add_tests(dec_literal_bsv, ['0', '1', '2', '42'], ['1a', 'hello', 'world'])
add_tests(int_literal_bsv, ['0', '1', '\'1', '\'0', '20152', "'hf0A", "201'hfff", "'b10110", "8'b11111111"], ["'b00101001012"])

# tokens
def token(x):
    return pp.Suppress(pp.Literal(x))

# keywords
kw_package = pp.Keyword('package')
kw_endpackage = pp.Keyword('endpackage')
kw_import = pp.Keyword('import')
kw_export = pp.Keyword('export')
kw_module = pp.Keyword('module')
kw_endmodule = pp.Keyword('endmodule')
kw_typeclass = pp.Keyword('typeclass')
kw_endtypeclass = pp.Keyword('endtypeclass')
kw_instance = pp.Keyword('instance')
kw_endinstance = pp.Keyword('endinstance')
kw_function = pp.Keyword('function')
kw_endfunction = pp.Keyword('endfunction')
kw_type = pp.Keyword('type')
kw_typedef = pp.Keyword('typedef')
kw_enum = pp.Keyword('enum')
kw_union = pp.Keyword('union')
kw_tagged = pp.Keyword('tagged')
kw_struct = pp.Keyword('struct')
kw_numeric = pp.Keyword('numeric')
kw_deriving = pp.Keyword('deriving')
kw_provisos = pp.Keyword('provisos')
kw_dependencies = pp.Keyword('dependencies')
kw_determines = pp.Keyword('determines')

add_tests(kw_module + ';', ['module;'], [])
add_tests(kw_module + 's', [], ['modules'])
add_tests(kw_module + '_', [], ['module_'])
add_tests(kw_module + '2', [], ['module2'])

# packages, imports, and exports
#package_bsv = kw_package + Identifier_bsv + ';' + \
#              pp.ZeroOrMore(~kw_endpackage + pp.Word(pp.printables)) + \
#              kw_endpackage + pp.Optional(':' + Identifier_bsv)
package_bsv = kw_package + Identifier_bsv('name') + ';'
import_bsv = kw_import + Identifier_bsv + pp.Literal('::') + pp.Literal('*') + pp.Literal(';')
export_bsv = kw_export + anyIdentifier_bsv + pp.Optional(pp.Literal('(') + pp.Literal('..') + pp.Literal(')')) + ';'

# type
type_bsv = pp.Forward()
function_type_bsv = kw_function + type_bsv + identifier_bsv + token('(') + pp.delimitedList(type_bsv + identifier_bsv) + token(')')
type_bsv <<     (function_type_bsv \
            |   (pp.Optional(anyIdentifier_bsv('package') + '::') + anyIdentifier_bsv('name') + \
                pp.Optional( pp.Suppress('#') + pp.Suppress('(') + pp.Group(pp.delimitedList(type_bsv, ','))('formal_args') + pp.Suppress(')') )) \
            |   (int_literal_bsv('numeric'))).setParseAction(parse_type)

add_tests(type_bsv, ['a', 'WriteReq', 'Bool', 'function Bit#(1) f(Bit#(1) x)', 'void', 'Bit#(2)', 'List::List#(t)', 'Vector#(2, Reg#(Bit#(32)))'], ['Vector#(2 Reg#(Bit#(5)))', 'A#(B#(C#(a))'])

# terms used in typedef definitions
union_member_bsv = pp.Forward()
type_formal_bsv = pp.Optional(kw_numeric) + kw_type + identifier_bsv
type_formals_bsv = token('#') + token('(') + pp.Group(pp.delimitedList(type_formal_bsv, ',')) + token(')')
typedef_type_bsv = Identifier_bsv + pp.Optional(type_formals_bsv)
deriving_bsv = pp.Optional(kw_deriving + token('(') + pp.Group(pp.delimitedList(Identifier_bsv, ',')) + token(')'), default = [])
subunion_bsv = kw_union + kw_tagged + token('{') + pp.OneOrMore(union_member_bsv) + token('}')
struct_member_bsv = (type_bsv + identifier_bsv + token(';')) | (subunion_bsv + Identifier_bsv + token(';'))
substruct_bsv = kw_struct + token('{') + pp.OneOrMore(struct_member_bsv) + token('}')
union_member_bsv << ((type_bsv + Identifier_bsv + token(';')) | (subunion_bsv + Identifier_bsv + token(';')) | (substruct_bsv + Identifier_bsv + token(';')))
enum_element_bsv = Identifier_bsv + pp.Optional(token('=') + int_literal_bsv) # TODO also support [intLiteral] and [intLiteral:intLiteral]

# typedefs
basic_typedef_bsv = kw_typedef + type_bsv + typedef_type_bsv('name') + token(';');
enum_typedef_bsv = kw_typedef + kw_enum + token('{') + pp.delimitedList(enum_element_bsv, ',') + token('}') + typedef_type_bsv('name') + deriving_bsv + token(';')
struct_typedef_bsv = kw_typedef + kw_struct + token('{') + pp.OneOrMore(struct_member_bsv) + token('}') + typedef_type_bsv('name') + deriving_bsv + token(';')
union_typedef_bsv = kw_typedef + kw_union + kw_tagged + token('{') + pp.OneOrMore(union_member_bsv) + token('}') + typedef_type_bsv('name') + deriving_bsv + token(';')
typedef_bsv = basic_typedef_bsv | enum_typedef_bsv | struct_typedef_bsv | union_typedef_bsv

# typedef tests
add_tests(basic_typedef_bsv, ['typedef a MyA;'], ['typedef x y;'])

# provisos
provisos_bsv = pp.Optional(kw_provisos + token('(') + pp.Group(pp.delimitedList(type_bsv, ',')) + token(')'), default = [])

# module
module_bsv = kw_module + pp.Optional(token('[') + type_bsv + token(']')) + identifier_bsv('name') + \
             pp.ZeroOrMore(~kw_endmodule + pp.Word(pp.printables)) + \
             kw_endmodule + pp.Optional(token(':') + identifier_bsv)

# module tests
add_tests(module_bsv, ["module[m] mkTest(); endmodule : mkTest"], [])

# function
# functions can take function as arguments, and the syntax does not match "type_bsv + identifier_bsv" so I made the identifier optional
function_bsv = pp.Forward()
function_bsv << (kw_function + pp.Optional(type_bsv) + identifier_bsv('name') + pp.Optional( token('(') + pp.Group(pp.delimitedList(type_bsv + pp.Optional(identifier_bsv), ',')) + token(')'), default=[] )('args') + provisos_bsv + token(';') + \
                pp.ZeroOrMore(pp.Group(function_bsv) | (~kw_endfunction + pp.Word(pp.printables))) + \
                kw_endfunction + pp.Optional(token(':') + identifier_bsv))

# typeclass
type_list_bsv = identifier_bsv | (token('(') + pp.delimitedList(identifier_bsv, ',') + token(')'))
type_depend_bsv = type_list_bsv + kw_determines + type_list_bsv
type_depends_bsv = pp.Optional(kw_dependencies + token('(') + pp.delimitedList(type_depend_bsv, ',') + token(')'))
typeclass_bsv = kw_typeclass + Identifier_bsv('name') + type_formals_bsv('formal_args') + provisos_bsv + type_depends_bsv + token(';') + \
                pp.ZeroOrMore(~kw_endtypeclass + pp.Word(pp.printables)) + \
                kw_endtypeclass + pp.Optional(token(':') + Identifier_bsv)

# typeclass tests

# instances
instance_bsv = kw_instance + Identifier_bsv('name') + token('#') + token('(') + pp.Group(pp.delimitedList(type_bsv, ','))('formal_args') + token(')') + provisos_bsv + token(';') + \
               pp.ZeroOrMore(~kw_endinstance + pp.Word(pp.printables)) + \
               kw_endinstance + pp.Optional(token(':') + Identifier_bsv)

# interface
kw_interface = pp.Keyword('interface')
kw_endinterface = pp.Keyword('endinterface')
interface_bsv = kw_interface + Identifier_bsv('name') + pp.Optional(type_formals_bsv) + token(';') + \
                pp.ZeroOrMore(~kw_endinterface + pp.Word(pp.printables)) + \
                kw_endinterface + pp.Optional(token(':') + Identifier_bsv)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('ERROR: expected a bsv filename or --test')
        exit(1)
    if sys.argv[1] == '--test' or sys.argv[1] == '-test':
        errors = run_tests()
        if errors > 0:
            print('ERROR: Found ' + str(errors) + ' errors')
            exit(1)
        else:
            exit(0)
    with open(sys.argv[1]) as f:
        file_data = f.read()
        # scan_result = (typedef_bsv | typeclass_bsv | instance_bsv | module_bsv).ignore(comment_bsv).scanString(file_data)
        def save_doc_comment(toks):
            global doc_comment
            try:
                toks.insert(0, doc_comment)
                doc_comment = ''
                return toks
            except TypeError as e:
                print('ERROR: type error in save_doc_comment: ' + str(e))
                print('type(toks) = ' + str(type(toks)))
                exit(1)
        scan_result = (comment_bsv | (package_bsv | typedef_bsv | interface_bsv | typeclass_bsv | instance_bsv | module_bsv | function_bsv).addParseAction(save_doc_comment)).scanString(file_data)
        for (x, y, z) in scan_result:
            if 'name' in x:
                line = pp.lineno(y, file_data)
                if x[1] == 'package':
                    print('# ' + str(x['name']))
                elif 'formal_args' in x:
                    # print('## ' + str(x['name']) + '#(' + str(x['formal_args']) + ')')
                    # print('### ' + str(x['name']))
                    print('### [' + str(x['name']) + '](../../' + sys.argv[1] + '#L' + str(line) + ')')
                else:
                    # print('### ' + str(x['name']))
                    print('### [' + str(x['name']) + '](../../' + sys.argv[1] + '#L' + str(line) + ')')
                if x[0] != '':
                    print(x[0])
                if x[1] != 'package':
                    print("```bluespec")
                    print(file_data[y:z])
                    print("```")
                print('')
        
