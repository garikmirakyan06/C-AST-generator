D			[0-9]
L			[a-zA-Z_]
H			[a-fA-F0-9]
E			([Ee][+-]?{D}+)
P                       ([Pp][+-]?{D}+)
FS			(f|F|l|L)
IS                      ((u|U)|(u|U)?(l|L|ll|LL)|(l|L|ll|LL)(u|U))


%{
	#include <iostream>
	#include <cstdlib>
	#include "scanner.h"
	#include "interpreter.h"
	#include "parser.tab.hpp"
	#include "location.hh"

	#define yyterminate() parser::Parser::make_END(parser::location());

	#define YY_USER_ACTION m_driver.increaseLocation(yyleng);

%}

%option nodefault
%option noyywrap
%option c++
%option yyclass="Scanner"
%option prefix="parser_"

%%



"void"                       return parser::Parser::make_VOID(parser::location());
"char"                       return parser::Parser::make_CHAR(parser::location());
"short"                      return parser::Parser::make_SHORT(parser::location());
"int"                        return parser::Parser::make_INT(parser::location());
"long"                       return parser::Parser::make_LONG(parser::location());
"float"                      return parser::Parser::make_FLOAT(parser::location());
"double"                     return parser::Parser::make_DOUBLE(parser::location());
"unsigned"                   return parser::Parser::make_UNSIGNED(parser::location());

"typedef"                    return parser::Parser::make_TYPEDEF(parser::location());
"extern"                     return parser::Parser::make_EXTERN(parser::location());
"static"                     return parser::Parser::make_STATIC(parser::location());
"auto"                       return parser::Parser::make_AUTO(parser::location());

"const"                      return parser::Parser::make_CONST(parser::location());
"volatile"                   return parser::Parser::make_VOLATILE(parser::location());



"="                    return parser::Parser::make_ASSIGN(parser::location());
";"                    return parser::Parser::make_SEMICOLON(parser::location());
","                    return parser::Parser::make_COMMA(parser::location());
"("                    return parser::Parser::make_LPAREN(parser::location());
")"                    return parser::Parser::make_RPAREN(parser::location());
("["|"<:")             return parser::Parser::make_LBRACKET(parser::location());
("]"|":>")             return parser::Parser::make_RBRACKET(parser::location());
("{"|"<%")             return parser::Parser::make_LBRACE(parser::location());
("}"|"%>")             return parser::Parser::make_RBRACE(parser::location());


{L}({L}|{D})*		         { return parser::Parser::make_IDENTIFIER(yytext, parser::location()); }

0[xX]{H}+{IS}?		         { return parser::Parser::make_CONSTANT(yytext, parser::location()); }
0[0-7]*{IS}?		         { return parser::Parser::make_CONSTANT(yytext, parser::location()); }
[1-9]{D}*{IS}?		         { return parser::Parser::make_CONSTANT(yytext, parser::location()); }
L?'(\\.|[^\\'\n])+'	         { return parser::Parser::make_CONSTANT(yytext, parser::location()); }

{D}+{E}{FS}?		         { return parser::Parser::make_CONSTANT(yytext, parser::location()); }
{D}*"."{D}+{E}?{FS}?	     { return parser::Parser::make_CONSTANT(yytext, parser::location()); }
{D}+"."{D}*{E}?{FS}?	     { return parser::Parser::make_CONSTANT(yytext, parser::location()); }
0[xX]{H}+{P}{FS}?	         { return parser::Parser::make_CONSTANT(yytext, parser::location()); }
0[xX]{H}*"."{H}+{P}?{FS}?    { return parser::Parser::make_CONSTANT(yytext, parser::location()); }
0[xX]{H}+"."{H}*{P}?{FS}?    { return parser::Parser::make_CONSTANT(yytext, parser::location()); }

L?\"(\\.|[^\\"\n])*\"        { return parser::Parser::make_STRING_LITERAL(yytext, parser::location()); }

">>="			{ return parser::Parser::make_RIGHT_ASSIGN(parser::location()); }
"<<="			{ return parser::Parser::make_LEFT_ASSIGN(parser::location()); }
"+="			{ return parser::Parser::make_ADD_ASSIGN(parser::location()); }
"-="			{ return parser::Parser::make_SUB_ASSIGN(parser::location()); }
"*="			{ return parser::Parser::make_MUL_ASSIGN(parser::location()); }
"/="			{ return parser::Parser::make_DIV_ASSIGN(parser::location()); }
"%="			{ return parser::Parser::make_MOD_ASSIGN(parser::location()); }
"&="			{ return parser::Parser::make_AND_ASSIGN(parser::location()); }
"^="			{ return parser::Parser::make_XOR_ASSIGN(parser::location()); }
"|="			{ return parser::Parser::make_OR_ASSIGN(parser::location()); }
">>"			{ return parser::Parser::make_RIGHT_OP(parser::location()); }
"<<"			{ return parser::Parser::make_LEFT_OP(parser::location()); }
"++"			{ return parser::Parser::make_INC_OP(parser::location()); }
"--"			{ return parser::Parser::make_DEC_OP(parser::location()); }
"->"			{ return parser::Parser::make_PTR_OP(parser::location()); }
"&&"			{ return parser::Parser::make_AND_OP(parser::location()); }
"||"			{ return parser::Parser::make_OR_OP(parser::location()); }
"<="			{ return parser::Parser::make_LE_OP(parser::location()); }
">="			{ return parser::Parser::make_GE_OP(parser::location()); }
"=="			{ return parser::Parser::make_EQ_OP(parser::location()); }
"!="			{ return parser::Parser::make_NE_OP(parser::location()); }

"."     return parser::Parser::make_DOT(parser::location());
"&"     return parser::Parser::make_AMP(parser::location());
"!"     return parser::Parser::make_EXCLAM(parser::location());
"~"     return parser::Parser::make_TILDE(parser::location());
"-"     return parser::Parser::make_MINUS(parser::location());
"+"     return parser::Parser::make_PLUS(parser::location());
"*"     return parser::Parser::make_MULT(parser::location());
"/"     return parser::Parser::make_DIV(parser::location());
"%"     return parser::Parser::make_PERCENT(parser::location());
"<"     return parser::Parser::make_LT(parser::location());
">"     return parser::Parser::make_GT(parser::location());
"^"     return parser::Parser::make_CARET(parser::location());
"|"     return parser::Parser::make_PIPE(parser::location());
"?"     return parser::Parser::make_QUESTION(parser::location());


.|\n
<<EOF>>     { return yyterminate(); }


%%