#include "interpreter.h"

#include <sstream>

using namespace parser;

Interpreter::Interpreter() :
    //m_commands(),
    m_scanner(*this),
    m_parser(m_scanner, *this),
    m_location(0)
{

}

int Interpreter::parse() {
    m_location = 0;
    return m_parser.parse();
}

void Interpreter::clear() {
    m_location = 0;
}

std::string Interpreter::str() const {

}

void Interpreter::switchInputStream(std::istream *is) {

}

void Interpreter::increaseLocation(unsigned int loc) {
    m_location += loc;
}

unsigned int Interpreter::location() const {
    return m_location;
}

