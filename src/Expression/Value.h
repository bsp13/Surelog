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
 * File:   Value.h
 * Author: alain
 *
 * Created on October 29, 2017, 10:33 PM
 */

#ifndef VALUE_H
#define VALUE_H

#include <stdint.h>
#include <string>
#include <iostream>
namespace SURELOG {

class Expr;
class LValue;
class StValue;
class ValueFactory;

class Value {
 public:
  friend Expr;
  friend ValueFactory;

  enum class Type {
    None,
    Binary,
    Hexadecimal,
    Octal,
    Unsigned,
    Integer,
    Double,
    String,
    Scalar
  };

  virtual ~Value() {}

  virtual unsigned short getSize() const = 0;  // size in bits

  // nb of 64 bits words necessary to encode the size
  virtual unsigned short getNbWords() const = 0;

  virtual Type getType() const = 0;
 
  // return false if the value is not valid (like nan)
  virtual bool isValid() const = 0;
  virtual void setInvalid() = 0;

  // is large value (more than one 64 bit word)
  virtual bool isLValue() const = 0;

  virtual uint64_t getValueUL(unsigned short index = 0) const = 0;
  virtual int64_t getValueL(unsigned short index = 0) const = 0;
  virtual double getValueD(unsigned short index = 0) const = 0;
  virtual std::string getValueS() const = 0;

  virtual void set(uint64_t val) = 0;
  virtual void set(int64_t val) = 0;
  virtual void set(double val) = 0;
  virtual void set(uint64_t val, Type type, unsigned short size) = 0;
  virtual void set(const std::string& val) = 0;
  virtual void set(const std::string& val, Type type) = 0;
  virtual bool operator<(const Value& rhs) const = 0;
  virtual bool operator==(const Value& rhs) const = 0;

  bool operator>(const Value& rhs) const { return rhs < (*this); }
  bool operator<=(const Value& rhs) const { return !(*this > rhs); }
  bool operator>=(const Value& rhs) const { return !(*this < rhs); }
  bool operator!=(const Value& rhs) const { return !((*this) == rhs); }

  virtual std::string uhdmValue() = 0;

  virtual void u_plus(const Value* a) = 0;
  virtual void u_minus(const Value* a) = 0;
  virtual void u_not(const Value* a) = 0;
  virtual void u_tilda(const Value* a) = 0;
  virtual void incr() = 0;
  virtual void decr() = 0;
  virtual void plus(const Value* a, const Value* b) = 0;
  virtual void minus(const Value* a, const Value* b) = 0;
  virtual void mult(const Value* a, const Value* b) = 0;
  virtual void div(const Value* a, const Value* b) = 0;
  virtual void mod(const Value* a, const Value* b) = 0;

  virtual void greater(const Value* a, const Value* b) = 0;
  virtual void greater_equal(const Value* a, const Value* b) = 0;
  virtual void lesser(const Value* a, const Value* b) = 0;
  virtual void lesser_equal(const Value* a, const Value* b) = 0;
  virtual void equiv(const Value* a, const Value* b) = 0;
  virtual void logAnd(const Value* a, const Value* b) = 0;
  virtual void logOr(const Value* a, const Value* b) = 0;
  virtual void bitwAnd(const Value* a, const Value* b) = 0;
  virtual void bitwOr(const Value* a, const Value* b) = 0;
  virtual void bitwXor(const Value* a, const Value* b) = 0;
  virtual void notEqual(const Value* a, const Value* b) = 0;
  virtual void shiftLeft(const Value* a, const Value* b) = 0;
  virtual void shiftRight(const Value* a, const Value* b) = 0;

 protected:
  unsigned int nbWords_(unsigned int size);
};

class SValue : public Value {
  friend LValue;

 public:
  SValue() : m_value(0), m_size(0), m_valid(1) {}
  SValue(uint64_t val, unsigned short size) : m_value(val), m_size(size), m_valid(1) {}
  SValue(uint64_t val) : SValue(val, 64) {}
  SValue(int64_t val) : SValue(val, 64) {}
  SValue(double val) : SValue((uint64_t)val, 64) {}
  ~SValue() final;

  unsigned short getSize() const final { return m_size; }
  unsigned short getNbWords() const final { return 1; }
  bool isLValue() const final { return false; }
  Type getType() const final { return Type::None; }
  bool isValid() const final { return m_valid; }
  void setInvalid() final { m_valid = 0; }
  void set(uint64_t val) final;
  void set(int64_t val) final;
  void set(double val) final;
  void set(uint64_t val, Type type, unsigned short size) final;
  void set(const std::string& val) final {
    m_value = 0;
    m_size = 0;
    m_valid = false;
  }
  void set(const std::string& val, Type type) final {
    m_value = 0;
    m_size = 0;
    m_valid = false;
  }

  bool operator<(const Value& rhs) const final {
    return m_value < (dynamic_cast<const SValue*>(&rhs))->m_value;
  }
  bool operator==(const Value& rhs) const final {
    return m_value == (dynamic_cast<const SValue*>(&rhs))->m_value;
  }
  uint64_t getValueUL(unsigned short index = 0) const final { return m_value; }
  int64_t getValueL(unsigned short index = 0) const final {
    return (int64_t)m_value;
  }
  double getValueD(unsigned short index = 0) const final {
    return (double)m_value;
  }
  std::string getValueS() const final { return "NOT_A_STRING_VALUE"; }

  std::string uhdmValue() final;

  void u_plus(const Value* a) final;
  void u_minus(const Value* a) final;
  void u_not(const Value* a) final;
  void u_tilda(const Value* a) final;
  void incr() final;
  void decr() final;
  void plus(const Value* a, const Value* b) final;
  void minus(const Value* a, const Value* b) final;
  void mult(const Value* a, const Value* b) final;
  void div(const Value* a, const Value* b) final;
  void mod(const Value* a, const Value* b) final;
  void greater(const Value* a, const Value* b) final;
  void greater_equal(const Value* a, const Value* b) final;
  void lesser(const Value* a, const Value* b) final;
  void lesser_equal(const Value* a, const Value* b) final;
  void equiv(const Value* a, const Value* b) final;
  void logAnd(const Value* a, const Value* b) final;
  void logOr(const Value* a, const Value* b) final;
  void bitwAnd(const Value* a, const Value* b) final;
  void bitwOr(const Value* a, const Value* b) final;
  void bitwXor(const Value* a, const Value* b) final;
  void notEqual(const Value* a, const Value* b) final;
  void shiftLeft(const Value* a, const Value* b) final;
  void shiftRight(const Value* a, const Value* b) final;

 private:
  uint64_t m_value;
  unsigned short m_size;
  unsigned short m_valid;
};

class ValueFactory {
 public:
  ValueFactory();
  Value* newSValue();
  Value* newLValue();
  Value* newStValue();
  Value* newValue(SValue& initVal);
  Value* newValue(LValue& initVal);
  Value* newValue(StValue& initVal);
  void deleteValue(Value*);

 protected:
  LValue* m_headFree;
  LValue* m_headInUse;
};

class LValue : public Value {
  friend ValueFactory;

 public:
  LValue(const LValue&);
  LValue() : m_type(Type::None), m_nbWords(0), m_valueArray(nullptr), m_valid(0) {}
  LValue(Type type, SValue* values, unsigned short nbWords)
    : m_type(type), m_nbWords(nbWords), m_valueArray(values), m_valid(1) {}
  LValue(uint64_t val);
  LValue(int64_t val);
  LValue(double val);
  LValue(uint64_t val, Type type, unsigned short size);
  ~LValue() final;

  unsigned short getSize() const final;
  unsigned short getNbWords() const final { return m_nbWords; }
  bool isLValue() const final { return true; }
  Type getType() const final { return m_type; }
  bool isValid() const final { return m_valid; }
  void setInvalid() final { m_valid = 0; }
  void set(uint64_t val) final;
  void set(int64_t val) final;
  void set(double val) final;
  void set(uint64_t val, Type type, unsigned short size) final;
  void set(const std::string& val) final {}
  void set(const std::string& val, Type type) final {}
  bool operator<(const Value& rhs) const final;
  bool operator==(const Value& rhs) const final;

  uint64_t getValueUL(unsigned short index = 0) const final {
    return ((index < m_nbWords) ? m_valueArray[index].m_value : 0);
  }
  int64_t getValueL(unsigned short index = 0) const final {
    return ((index < m_nbWords) ? (int64_t)m_valueArray[index].m_value : 0);
  }
  double getValueD(unsigned short index = 0) const final {
    return ((index < m_nbWords) ? (double)m_valueArray[index].m_value : 0);
  }
  std::string getValueS() const final { return "NOT_A_STRING_VALUE"; }

  std::string uhdmValue() final;

  void u_plus(const Value* a) final;
  void u_minus(const Value* a) final;
  void u_not(const Value* a) final;
  void u_tilda(const Value* a) final;
  void incr() final;
  void decr() final;
  void plus(const Value* a, const Value* b) final;
  void minus(const Value* a, const Value* b) final;
  void mult(const Value* a, const Value* b) final;
  void div(const Value* a, const Value* b) final;
  void mod(const Value* a, const Value* b) final;
  void greater(const Value* a, const Value* b) final;
  void greater_equal(const Value* a, const Value* b) final;
  void lesser(const Value* a, const Value* b) final;
  void lesser_equal(const Value* a, const Value* b) final;
  void equiv(const Value* a, const Value* b) final;
  void logAnd(const Value* a, const Value* b) final;
  void logOr(const Value* a, const Value* b) final;
  void bitwAnd(const Value* a, const Value* b) final;
  void bitwOr(const Value* a, const Value* b) final;
  void bitwXor(const Value* a, const Value* b) final;
  void notEqual(const Value* a, const Value* b) final;
  void shiftLeft(const Value* a, const Value* b) final;
  void shiftRight(const Value* a, const Value* b) final;

  void adjust(const Value* a);

 private:
  Type m_type;
  unsigned short m_nbWords;
  SValue* m_valueArray;
  unsigned short m_valid;
  LValue* m_prev;
  LValue* m_next;
};

class StValue : public Value {
  friend LValue;

 public:
  StValue() : m_type(Type::String), m_value(""), m_size(0), m_valid(false) {}
  StValue(const std::string& val) :  m_type(Type::String), m_value(val), m_size(val.size()), m_valid(true) {}
  ~StValue() final;

  unsigned short getSize() const final { return m_size; }
  unsigned short getNbWords() const final { return 1; }
  bool isLValue() const final { return false; }
  Type getType() const final { return m_type; }
  bool isValid() const final { return m_valid; }
  void setInvalid() final { m_valid = false; }
  void set(uint64_t val) final { m_type = Type::Unsigned; m_value = std::to_string(val); m_valid = true; }
  void set(int64_t val) final { m_type = Type::Integer; m_value = std::to_string(val); m_valid = true; }
  void set(double val) final { m_type = Type::Double; m_value = std::to_string(val); m_valid = true; }
  void set(uint64_t val, Type type, unsigned short size) final {
    m_type = type;
    m_value = std::to_string(val);
    m_size = size;
    m_valid = true;
  }
  void set(const std::string& val, Type type) final {
    m_type = type;
    m_value = val;
    m_size = val.size();
    m_valid = true;
  }
  void set(const std::string& val) final {
    m_type = Type::String;
    m_value = val;
    m_size = val.size();
    m_valid = true;
  }
  bool operator<(const Value& rhs) const final {
    return m_value < (dynamic_cast<const StValue*>(&rhs))->m_value;
  }
  bool operator==(const Value& rhs) const final {
    return m_value == (dynamic_cast<const StValue*>(&rhs))->m_value;
  }
  uint64_t getValueUL(unsigned short index = 0) const final {
    return atol(m_value.c_str());
  }
  int64_t getValueL(unsigned short index = 0) const final {
    return (int64_t)atol(m_value.c_str());
  }
  double getValueD(unsigned short index = 0) const final {
    return strtod(m_value.c_str(), NULL);
  }
  std::string getValueS() const final { return m_value; }

  std::string uhdmValue() final;

  void u_plus(const Value* a) final {}
  void u_minus(const Value* a) final {}
  void u_not(const Value* a) final {}
  void u_tilda(const Value* a) final {}
  void incr() final {}
  void decr() final {}
  void plus(const Value* a, const Value* b) final {}
  void minus(const Value* a, const Value* b) final {}
  void mult(const Value* a, const Value* b) final {}
  void div(const Value* a, const Value* b) final {}
  void mod(const Value* a, const Value* b) final {}
  void greater(const Value* a, const Value* b) final {}
  void greater_equal(const Value* a, const Value* b) final {}
  void lesser(const Value* a, const Value* b) final {}
  void lesser_equal(const Value* a, const Value* b) final {}
  void equiv(const Value* a, const Value* b) final;
  void logAnd(const Value* a, const Value* b) final {}
  void logOr(const Value* a, const Value* b) final {}
  void bitwAnd(const Value* a, const Value* b) final {}
  void bitwOr(const Value* a, const Value* b) final {}
  void bitwXor(const Value* a, const Value* b) final {}
  void notEqual(const Value* a, const Value* b) final;
  void shiftLeft(const Value* a, const Value* b) final {}
  void shiftRight(const Value* a, const Value* b) final {}

 private:
  Type m_type;
  std::string m_value;
  unsigned short m_size;
  unsigned short m_valid;
};

};  // namespace SURELOG

#endif /* VALUE_H */
