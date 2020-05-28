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
 * File:   Netlist.h
 * Author: alain
 *
 * Created on April 15, 2019, 8:03 PM
 */

#ifndef NETLIST_H
#define NETLIST_H
#include <string>
#include <vector>
#include <map>
#include "SourceCompile/SymbolTable.h"
#include "Design/FileContent.h"
#include "Design/ModPort.h"
#include "headers/uhdm_forward_decl.h"

namespace SURELOG {

class ModuleInstance;

class Netlist {
 public:
  Netlist(ModuleInstance* parent) : m_parent(parent), m_interfaces(nullptr), m_nets(nullptr), 
                                    m_ports(nullptr), m_gen_scope_arrays(nullptr), m_array_vars(nullptr) {}
  ~Netlist();

  typedef std::map<std::string, std::pair<ModPort*, UHDM::modport*>> ModPortMap;
  typedef std::map<std::string, std::pair<ModuleInstance*, UHDM::BaseClass*>> InstanceMap;
  typedef std::map<std::string, UHDM::BaseClass*> SymbolTable;

  std::vector<UHDM::interface*>*   interfaces() { return m_interfaces; }
  std::vector<UHDM::port*>*        ports() { return m_ports;}
  std::vector<UHDM::net*>*         nets() { return m_nets;}
  std::vector<UHDM::gen_scope_array*>*  gen_scopes() { return m_gen_scope_arrays; }
  std::vector<UHDM::array_var*>*        array_vars() { return m_array_vars;}

  void interfaces(std::vector<UHDM::interface*>* interfaces) { m_interfaces = interfaces; }
  void ports(std::vector<UHDM::port*>* ports) { m_ports = ports;}
  void nets(std::vector<UHDM::net*>* nets) { m_nets = nets;}
  void gen_scopes(std::vector<UHDM::gen_scope_array*>* gen_scopes) {m_gen_scope_arrays = gen_scopes; } 
  void array_vars(std::vector<UHDM::array_var*>* array_vars) {m_array_vars = array_vars; } 

  std::vector<UHDM::port*>& actualPorts() { return m_actualPorts;}
  SymbolTable&  getSymbolTable() { return m_symbolTable; }
  ModPortMap& getModPortMap() { return m_modPortMap; }
  InstanceMap& getInstanceMap() { return m_instanceMap; }
  ModuleInstance* getParent() { return m_parent; }
 private:
  ModuleInstance*                  m_parent;
  std::vector<UHDM::interface*>*   m_interfaces;
  std::vector<UHDM::net*>*         m_nets;
  std::vector<UHDM::port*>*        m_ports;
  std::vector<UHDM::gen_scope_array*>* m_gen_scope_arrays;
  std::vector<UHDM::array_var*>* m_array_vars;
  // Helpers
  std::vector<UHDM::port*> m_actualPorts;
  SymbolTable m_symbolTable;
  ModPortMap m_modPortMap;
  InstanceMap m_instanceMap;
};

};  // namespace SURELOG

#endif /* NETLIST_H */