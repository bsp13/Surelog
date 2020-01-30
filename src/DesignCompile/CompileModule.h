/*
 Copyright 2019 Alain Dargelas

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

/*
 * File:   CompileModule.h
 * Author: alain
 *
 * Created on March 22, 2018, 9:43 PM
 */

#ifndef COMPILEMODULE_H
#define COMPILEMODULE_H

#include "DesignCompile/CompileHelper.h"

namespace SURELOG {

struct FunctorCompileModule {
  FunctorCompileModule(CompileDesign* compiler, ModuleDefinition* module,
                       Design* design, SymbolTable* symbols,
                       ErrorContainer* errors)
      : m_compileDesign(compiler),
        m_module(module),
        m_design(design),
        m_symbols(symbols),
        m_errors(errors) {}
  int operator()() const;

 private:
  CompileDesign* m_compileDesign;
  ModuleDefinition* m_module;
  Design* m_design;
  SymbolTable* m_symbols;
  ErrorContainer* m_errors;
};

class CompileModule {
 public:
  CompileModule(CompileDesign* compiler, ModuleDefinition* module,
                Design* design, SymbolTable* symbols, ErrorContainer* errors)
      : m_compileDesign(compiler),
        m_module(module),
        m_design(design),
        m_symbols(symbols),
        m_errors(errors) {
    m_helper.seterrorReporting(errors, symbols);
  }

  bool compile();

  virtual ~CompileModule();

 private:
  bool collectModuleObjects_();
  bool checkModule_();
  bool collectInterfaceObjects_();
  bool checkInterface_();
  void compilePortDeclaration_(FileContent* fC, NodeId id, std::string& libName,
                               VObjectType& port_direction);
  void compileClockingBlock_(FileContent* fC, NodeId id);
  void compileNetDeclaration_(FileContent* fC, NodeId id, bool interface);
  void compileDataDeclaration_(FileContent* fC, NodeId id, bool interface);
  CompileDesign* m_compileDesign;
  ModuleDefinition* m_module;
  Design* m_design;
  SymbolTable* m_symbols;
  ErrorContainer* m_errors;
  CompileHelper m_helper;
};

};  // namespace SURELOG

#endif /* COMPILEMODULE_H */
