#ifndef SCANNER_H
#define SCANNER_H


/**
 * Generated Flex class name is yyFlexLexer by default. If we want to use more flex-generated
 * classes we should name them differently. See scanner.l prefix option.
 * 
 * Unfortunately the implementation relies on this trick with redefining class name
 * with a preprocessor macro. See GNU Flex manual, "Generating C++ Scanners" section
 */
#if ! defined(yyFlexLexerOnce)
#undef yyFlexLexer
#define yyFlexLexer parser_FlexLexer // the trick with prefix; no namespace here :(
#include <FlexLexer.h>
#endif

// Scanner method signature is defined by this macro. Original yylex() returns int.
// Sinice Bison 3 uses symbol_type, we must change returned type. We also rename it
// to something sane, since you cannot overload return type.
#undef YY_DECL
#define YY_DECL parser::Parser::symbol_type parser::Scanner::get_next_token()

#include "parser.tab.hpp"

namespace parser {

class Interpreter;
    
class Scanner : public yyFlexLexer {
public:
        Scanner(Interpreter &driver) : m_driver(driver) {}
	virtual ~Scanner() {}
	virtual parser::Parser::symbol_type get_next_token();
        
private:
    Interpreter &m_driver;
};

}

#endif
