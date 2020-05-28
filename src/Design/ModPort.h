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
 * File:   ModPort.h
 * Author: alain
 *
 * Created on January 31, 2020, 9:46 PM
 */
#include <vector>

#include "SourceCompile/SymbolTable.h"
#include "Signal.h"

#ifndef MODPORT_H
#define MODPORT_H
namespace SURELOG {

class ModuleDefinition;

class ModPort {
public:
  ModPort(ModuleDefinition* parent, const std::string& name) : m_parent(parent), m_name(name) {}
  virtual ~ModPort();
  const std::string& getName() { return m_name; }
  void addSignal(Signal& sig) { m_ports.push_back(sig); }
  std::vector<Signal>& getPorts() { return m_ports; }
  Signal* getPort(std::string& name);
  ModuleDefinition* getParent () { return m_parent; }
private:
  ModuleDefinition* m_parent;
  std::string m_name;
  std::vector<Signal> m_ports;
};
};

#endif /* MODPORT_H */
