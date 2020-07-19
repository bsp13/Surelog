#!/usr/bin/tclsh

# Copyright 2019 Alain Dargelas
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Optional parameter to provide an output directory
set DEST_DIR "."
if [regexp {out_dir=([a-zA-Z0-9_/\.:-]+)} $argv tmp DEST_DIR] {}

set LISTENERS                 "Parser PreProc"

set ANTLR_DEFINITION(Parser)  "parser/SV3_1aParserBaseListener.h"
set CPP_INPUT(Parser)         "SourceCompile/SV3_1aTreeShapeListener.cpp"
set HEADER_OUTPUT(Parser)     "SourceCompile/SV3_1aTreeShapeListener.h"

set ANTLR_DEFINITION(PreProc) "parser/SV3_1aPpParserBaseListener.h"
set CPP_INPUT(PreProc)        "SourceCompile/SV3_1aPpTreeShapeListener.cpp"
set HEADER_OUTPUT(PreProc)    "SourceCompile/SV3_1aPpTreeShapeListener.h"

set VOBJECTTYPES_CPP_BASENAME "SourceCompile/VObjectTypes"
set VOBJECTTYPES_PY_H         "API/vobjecttypes_py.h"

puts "Creating Parser listener $HEADER_OUTPUT(Parser) and object types ${VOBJECTTYPES_CPP_BASENAME}"

proc generate_header { listener } {
    global LISTENERS ANTLR_DEFINITION HEADER_OUTPUT CPP_INPUT TYPES DEST_DIR

    set oid [open "${DEST_DIR}/$HEADER_OUTPUT($listener)" "w"]

    # Read .cpp hand written methods
    set cid [open $CPP_INPUT($listener)]
    set cpp_spec "[read $cid]"
    close $cid
    set lines [split $cpp_spec "\n"]
    foreach line $lines {
      if {[regexp {::(enter[a-zA-Z0-9_]+)} $line tmp method] || [regexp {::(exit[a-zA-Z0-9_]+)} $line tmp method] || [regexp {::(visit[a-zA-Z0-9_]+)} $line tmp method]} {
          set CUSTOM_METHOD($method) 1
      }
    }

    # Read Listener definition
    set hid [open $ANTLR_DEFINITION($listener)]
    set h_spec "[read $hid]"
    close $hid
    set lines [split $h_spec "\n"]

    puts $oid "/*"
    puts $oid " Copyright 2019 Alain Dargelas"
    puts $oid " Licensed under the Apache License, Version 2.0 (the \"License\");"
    puts $oid " you may not use this file except in compliance with the License."
    puts $oid " You may obtain a copy of the License at"
    puts $oid ""
    puts $oid "    http://www.apache.org/licenses/LICENSE-2.0"
    puts $oid ""
    puts $oid " Unless required by applicable law or agreed to in writing, software"
    puts $oid " distributed under the License is distributed on an \"AS IS\" BASIS,"
    puts $oid " WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."
    puts $oid " See the License for the specific language governing permissions and"
    puts $oid " limitations under the License."
    puts $oid " */"
    puts $oid ""
    puts $oid "/*  This file is automatically generated by generate_parser_listener.tcl"
    puts $oid " *  DO NOT EDIT THIS FILE."
    puts $oid " *  If a method needs custom operator, write the method in $CPP_INPUT($listener)"
    puts $oid "*/"
    puts $oid ""
    puts $oid "/* "
    puts $oid " * File:   $HEADER_OUTPUT($listener)"
    puts $oid " * Author: alain"
    puts $oid " *"
    puts $oid " * Created on April 16, 2017, 8:28 PM"
    puts $oid " */"
    puts $oid ""
    if {$listener == "Parser"} {
        puts $oid "#ifndef SV3_1ATREESHAPELISTENER_H"
        puts $oid "#define SV3_1ATREESHAPELISTENER_H"
        puts $oid "#include <stack>"
        puts $oid "#include <map>"
        puts $oid "#include <unordered_map>"
        puts $oid "#include \"Utils/ParseUtils.h\""
        puts $oid "#include \"SourceCompile/SymbolTable.h\""
        puts $oid "#include \"Design/TimeInfo.h\""
        puts $oid "#include \"Design/DesignElement.h\""
        puts $oid "#include \"Design/FileContent.h\""
        puts $oid "#include \"SourceCompile/ParseFile.h\""
        puts $oid "#include \"SourceCompile/CompilationUnit.h\""
        puts $oid "#include \"SourceCompile/CompileSourceFile.h\""
        puts $oid "#include \"SourceCompile/SV3_1aTreeShapeHelper.h\""
        puts $oid ""
        puts $oid "namespace SURELOG \{"
        puts $oid ""
        puts $oid "    class SV3_1aTreeShapeListener : public SV3_1aParserBaseListener, public SV3_1aTreeShapeHelper  \{"
        puts $oid "    private:"
        puts $oid " "
        puts $oid "    public:"
        puts $oid "        SV3_1aTreeShapeListener(ParseFile* pf, antlr4::CommonTokenStream* tokens, unsigned int lineOffset);"
        puts $oid " "
        puts $oid "        ~SV3_1aTreeShapeListener();"
        puts $oid " "
    } else {
        puts $oid "#ifndef SV3_1APPTREESHAPELISTENER_H"
        puts $oid "#define SV3_1APPTREESHAPELISTENER_H"
        puts $oid ""
        puts $oid "#include <regex>"
        puts $oid ""
        puts $oid "#include \"SourceCompile/PreprocessFile.h\""
        puts $oid "#include \"SourceCompile/CompileSourceFile.h\""
        puts $oid "#include \"SourceCompile/Compiler.h\""
        puts $oid "#include \"SourceCompile/SymbolTable.h\""
        puts $oid "#include \"SourceCompile/CompilationUnit.h\""
        puts $oid "#include \"Design/TimeInfo.h\""
        puts $oid "#include \"SourceCompile/SV3_1aPpTreeListenerHelper.h\""
        puts $oid ""
        puts $oid "namespace SURELOG \{"
        puts $oid ""
        puts $oid "    class SV3_1aPpTreeShapeListener : public SV3_1aPpParserBaseListener , public SV3_1aPpTreeListenerHelper \{"
        puts $oid ""
        puts $oid "    public:"
        puts $oid ""
        puts $oid "    SV3_1aPpTreeShapeListener(PreprocessFile* pp, antlr4::CommonTokenStream* tokens, PreprocessFile::SpecialInstructions& instructions);"
        puts $oid ""
        puts $oid ""
    }

    foreach line $lines {
        if {[regexp {virtual void ([a-zA-Z0-9_]+)} $line tmp method]} {
            if [info exist CUSTOM_METHOD($method)] {
                regsub "virtual" $line "" line
                    regsub " override" $line " final" line
                regsub {\{ \}} $line ";" line

                if [regsub "exit" $method ""  method] {
                    regsub "enter" $method "" method
                    regsub "visit" $method "" method
                    set TYPES(sl${method}) 1
                }

                puts $oid $line
            } else {
                if [regsub "exit" $method ""  method] {
                    regsub "enter" $method "" method
                    regsub "visit" $method "" method
                    set code "addVObject (ctx, VObjectType::sl${method});"
                    regsub {\{ \}} $line "{ $code }" line
                    set TYPES(sl${method}) 1
                    regsub {/\*ctx\*/} $line "ctx" line
                }
                regsub "virtual" $line "" line
                    regsub " override" $line " final" line
                puts $oid $line
            }
        }
    }

    puts $oid "    \};"
    puts $oid "\};"
    puts $oid ""
    if {$listener == "Parser"} {
        puts $oid "#endif /* SV3_1ATREESHAPELISTENER_H */"
    } else {
        puts $oid "#endif /* SV3_1APPTREESHAPELISTENER_H */"
    }
    puts $oid ""
    close $oid
}

foreach listener $LISTENERS {
    generate_header $listener
}

set TYPES(slNoType) 1
set TYPES(slComments) 1
set TYPES(slModule) 1
# both Module_declaration and Interface_declaration enter and exit rules are in SV3_1aTreeShapeListener.cpp file
set TYPES(slModule_declaration) 1
set TYPES(slInterface_declaration) 1
# Class_type exit is in SV3_1aTreeShapeListener.cpp file
set TYPES(slClass_type) 1
set TYPES(slHierarchical_identifier) 1
set TYPES(slModuleInstance) 1
set TYPES(slPrimitive) 1
set TYPES(slPrimitiveInstance) 1
set TYPES(slInterface) 1
set TYPES(slProgram) 1
set TYPES(slPackage) 1
set TYPES(slChecker) 1
set TYPES(slClass) 1
set TYPES(slPortInst) 1
set TYPES(slConstSelect) 1
set TYPES(slIntConst) 1
set TYPES(slRealConst) 1
set TYPES(slStringConst) 1
set TYPES(slStringLiteral) 1
set TYPES(slConstantSelect) 1
set TYPES(slThis) 1
set TYPES(slGenericElementType) 1
set TYPES(sl0) 1
set TYPES(sl1) 1
set TYPES(slX) 1
set TYPES(slZ) 1
set TYPES(slNumber) 1
set TYPES(slText_blob) 1
set TYPES(slCR) 1
set TYPES(slSpaces) 1
set TYPES(slEscapedCR) 1

set TYPES(slEndfunction) 1
set TYPES(slEndmodule) 1
set TYPES(slEndclass) 1
set TYPES(slEndtask) 1
set TYPES(slEndchecker) 1
set TYPES(slEndinterface) 1
set TYPES(slEndprogram) 1
set TYPES(slEndpackage) 1
set TYPES(slEndcase) 1
set TYPES(slEndsequence) 1
set TYPES(slEnd) 1
set TYPES(slEndspecify) 1
set TYPES(slEndconfig) 1
set TYPES(slEndproperty) 1
set TYPES(slEndgroup) 1
set TYPES(slEndgenerate) 1
set TYPES(slEndprimitive) 1
set TYPES(slEndtable) 1
set TYPES(slEndclocking) 1
set TYPES(slUnique) 1
set TYPES(slUnique0) 1
set TYPES(slPriority) 1
set TYPES(slCase) 1
set TYPES(slCaseX) 1
set TYPES(slCaseZ) 1
set TYPES(slIncPartSelectOp) 1
set TYPES(slDecPartSelectOp) 1
set TYPES(slColumnPartSelectOp) 1
set TYPES(slReturnStmt) 1
set TYPES(slBreakStmt) 1
set TYPES(slContinueStmt) 1
set TYPES(slAssign) 1
set TYPES(slDeassign) 1
set TYPES(slForce) 1
set TYPES(slRelease) 1
set TYPES(slForever) 1
set TYPES(slRepeat) 1
set TYPES(slWhile) 1
set TYPES(slFor) 1
set TYPES(slDo) 1
set TYPES(slForeach) 1
set TYPES(slElse) 1

set TYPES(slSupply0) 1
set TYPES(slStrong0) 1
set TYPES(slPull0) 1
set TYPES(slWeak0) 1
set TYPES(slSupply1) 1
set TYPES(slStrong1) 1
set TYPES(slPull1) 1
set TYPES(slWeak1) 1
set TYPES(slHighZ1) 1
set TYPES(slHighZ0) 1
set TYPES(slSmall) 1
set TYPES(slMedium) 1
set TYPES(slLarge) 1
set TYPES(slDotStar) 1
set TYPES(slNonBlockingTriggerEvent) 1

set TYPES(slUnary_Plus) 1
set TYPES(slUnary_Minus) 1
set TYPES(slUnary_Not) 1
set TYPES(slUnary_Tilda) 1
set TYPES(slUnary_BitwAnd) 1
set TYPES(slUnary_BitwOr) 1
set TYPES(slUnary_BitwXor) 1
set TYPES(slUnary_ReductNand) 1
set TYPES(slUnary_ReductNor) 1
set TYPES(slUnary_ReductXnor1) 1
set TYPES(slUnary_ReductXnor2) 1
set TYPES(slBinOp_MultMult) 1
set TYPES(slBinOp_Mult) 1
set TYPES(slBinOp_Div) 1
set TYPES(slBinOp_Percent) 1
set TYPES(slBinOp_Plus) 1
set TYPES(slBinOp_Minus) 1
set TYPES(slBinOp_ShiftRight) 1
set TYPES(slBinOp_ShiftLeft) 1
set TYPES(slBinOp_ArithShiftRight) 1
set TYPES(slBinOp_ArithShiftLeft) 1
set TYPES(slBinOp_Less) 1
set TYPES(slBinOp_LessEqual) 1
set TYPES(slBinOp_Great) 1
set TYPES(slBinOp_GreatEqual) 1
set TYPES(slInsideOp) 1
set TYPES(slBinOp_Equiv) 1
set TYPES(slBinOp_Not) 1
set TYPES(slBinOp_WildcardEqual) 1
set TYPES(slBinOp_WildcardNotEqual) 1
set TYPES(slBinOp_FourStateLogicEqual) 1
set TYPES(slBinOp_FourStateLogicNotEqual) 1
set TYPES(slBinOp_WildEqual) 1
set TYPES(slBinOp_WildNotEqual) 1
set TYPES(slBinOp_BitwAnd) 1
set TYPES(slBinOp_ReductXnor1) 1
set TYPES(slBinOp_ReductXnor2) 1
set TYPES(slBinOp_ReductNand) 1
set TYPES(slBinOp_ReductNor) 1
set TYPES(slBinOp_BitwXor) 1
set TYPES(slBinOp_BitwOr) 1
set TYPES(slBinOp_LogicAnd) 1
set TYPES(slBinOp_LogicOr) 1
set TYPES(slBinOp_Imply) 1
set TYPES(slBinOp_Equivalence) 1
set TYPES(slIncDec_PlusPlus) 1
set TYPES(slIncDec_MinusMinus) 1
set TYPES(slTagged) 1
set TYPES(slQmark) 1
set TYPES(slMatches) 1

set TYPES(slAssignOp_Assign) 1
set TYPES(slAssignOp_Add) 1
set TYPES(slAssignOp_Sub) 1
set TYPES(slAssignOp_Mult) 1
set TYPES(slAssignOp_Div) 1
set TYPES(slAssignOp_Modulo) 1
set TYPES(slAssignOp_BitwAnd) 1
set TYPES(slAssignOp_BitwOr) 1
set TYPES(slAssignOp_BitwXor) 1
set TYPES(slAssignOp_BitwLeftShift) 1
set TYPES(slAssignOp_BitwRightShift) 1
set TYPES(slAssignOp_ArithShiftLeft) 1
set TYPES(slAssignOp_ArithShiftRight) 1

set TYPES(slIncDec_PlusPlus) 1
set TYPES(slIncDec_MinusMinus) 1

set TYPES(slNetType_Supply0) 1 
set TYPES(slNetType_Supply1) 1 
set TYPES(slNetType_Tri) 1 
set TYPES(slNetType_TriAnd) 1 
set TYPES(slNetType_TriOr) 1 
set TYPES(slNetType_TriReg) 1 
set TYPES(slNetType_Tri0) 1 
set TYPES(slNetType_Tri1) 1 
set TYPES(slNetType_Uwire) 1 
set TYPES(slNetType_Wire) 1
set TYPES(slNetType_Wand) 1 
set TYPES(slNetType_Wor) 1 

set oid [open "${DEST_DIR}/${VOBJECTTYPES_CPP_BASENAME}.h" "w"]
puts $oid ""
puts $oid "// This file is automatically generated by generate_parser_listener.tcl"
puts $oid "// DO NOT EDIT"
puts $oid ""
puts $oid "#ifndef VOBJECTTYPES_H"
puts $oid "#define VOBJECTTYPES_H"

puts $oid "enum VObjectType {"
set id 0
foreach type [lsort -dictionary [array names TYPES]] {
    puts $oid "      $type = $id,"
    incr id
}
puts $oid "};"
puts $oid ""
puts $oid "#endif /* VOBJECTTYPES_H */"
puts $oid ""

close $oid


set oid [open "${DEST_DIR}/${VOBJECTTYPES_CPP_BASENAME}.cpp" "w"]
puts $oid ""
puts $oid "#include <string>"
puts $oid "#include \"Design/VObject.h\""
puts $oid "// This file is automatically generated by generate_parser_listener.tcl"
puts $oid "// DO NOT EDIT"
puts $oid ""
puts $oid "using namespace SURELOG;"
puts $oid ""
puts $oid "std::string VObject::getTypeName(unsigned short type) {"
puts $oid "    std::string text;"
puts $oid "    switch (type) {"
foreach type [lsort -dictionary [array names TYPES]] {
    puts $oid "    case $type:"
    puts $oid "      text = \"$type\";"
    puts $oid "      break;"
}
puts $oid "    };"
puts $oid "    return text;"
puts $oid "}"
puts $oid ""
close $oid

set oid [open "${DEST_DIR}/${VOBJECTTYPES_PY_H}" "w"]
puts $oid ""
puts $oid "std::vector<std::string> slapi_types = {"
puts $oid "\"\# This file is automatically generated by generate_parser_listener.tcl\\n\""
puts $oid "\"\# DO NOT EDIT\\n\""

set id 0
foreach type [lsort -dictionary [array names TYPES]] {
    puts $oid "\"$type = $id;\\n\""
    incr id
}
puts $oid "};"

close $oid

flush stdout
