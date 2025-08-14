%skeleton "lalr1.cc"
%require "3.0"

%defines
%define api.parser.class { Parser }

%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define api.namespace { parser }

%code requires
{
    #include <iostream>
    #include <string>
    #include <vector>
    #include <stdint.h>
    #include "ast.h"

    using namespace std;

    namespace parser {
        class Scanner;
        class Interpreter;
    }

}


%code top
{
    #include <iostream>
    #include "scanner.h"
    #include "parser.tab.hpp"
    #include "interpreter.h"
    #include "location.hh"

    static parser::Parser::symbol_type yylex(parser::Scanner &scanner, parser::Interpreter &driver) {
        return scanner.get_next_token();
    }

    using namespace parser;
}

%lex-param { parser::Scanner &scanner }
%lex-param { parser::Interpreter &driver }
%parse-param { parser::Scanner &scanner }
%parse-param { parser::Interpreter &driver }
%locations
%define parse.trace
%define parse.error verbose

%define api.token.prefix {TOKEN_}



%token END 0 "end of file"

%token VOID CHAR SHORT INT LONG FLOAT DOUBLE UNSIGNED;
%token TYPEDEF EXTERN STATIC AUTO;
%token CONST VOLATILE;
%token <std::string> IDENTIFIER;
%token <std::string> CONSTANT "number literal";
%token <std::string> STRING_LITERAL "string literal";
%token ASSIGN '=';
%token SEMICOLON ';';
%token COMMA ',';
%token LPAREN '(';
%token RPAREN ')';
%token LBRACKET '[';
%token RBRACKET ']';
%token LBRACE '{';
%token RBRACE '}';

%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN
%token DOT "."
%token AMP "&"
%token EXCLAM "!"
%token TILDE "~"
%token MINUS "-"
%token PLUS "+"
%token MULT "*"
%token DIV "/"
%token PERCENT "%"
%token LT "<"
%token GT ">"
%token CARET "^"
%token PIPE "|"
%token QUESTION "?"

%left PLUS MINUS
%left MULT DIV


%type <std::string> storage_class_specifier type_specifier type_qualifier;
%type <std::shared_ptr<DeclSpec>> declaration_specifiers
%type <std::shared_ptr<Declarator>> declarator direct_declarator
%type <std::shared_ptr<TranslationUnit>> translation_unit
%type <std::vector<std::shared_ptr<Declaration>>> declaration external_declaration
%type <std::shared_ptr<Expr>> assignment_expression initializer
%type <std::shared_ptr<InitDeclarator>> init_declarator
%type <std::vector<std::shared_ptr<InitDeclarator>>> init_declarator_list

%type <std::shared_ptr<CompoundStmt>> compound_statement
%type <std::shared_ptr<FunctionDecl>> function_definition
%type <std::vector<std::shared_ptr<ASTNode>>> block_item_list
%type <std::shared_ptr<ASTNode>> block_item

%type <std::shared_ptr<Expr>> primary_expression expression postfix_expression unary_expression
%type <std::shared_ptr<Expr>> additive_expression multiplicative_expression cast_expression conditional_expression
%type <std::shared_ptr<Expr>> logical_or_expression logical_and_expression inclusive_or_expression exclusive_or_expression and_expression equality_expression relational_expression shift_expression


%start translation_unit



%%



cast_expression
	: unary_expression
//	| '(' type_name ')' cast_expression
	;


multiplicative_expression
    : cast_expression
    | multiplicative_expression MULT cast_expression
        { $$ = std::make_shared<BinaryOperator>("*", $1, $3); }
    | multiplicative_expression DIV cast_expression
        { $$ = std::make_shared<BinaryOperator>("/", $1, $3); }
    | multiplicative_expression PERCENT cast_expression
        { $$ = std::make_shared<BinaryOperator>("%", $1, $3); }
    ;


additive_expression
    : multiplicative_expression
    | additive_expression PLUS multiplicative_expression
        { $$ = std::make_shared<BinaryOperator>("+", $1, $3); }
    | additive_expression MINUS multiplicative_expression
        { $$ = std::make_shared<BinaryOperator>("-", $1, $3); }
    ;


assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;


shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression LT shift_expression
	| relational_expression GT shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression AMP equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression CARET and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression PIPE exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression QUESTION expression ':' conditional_expression
	;


unary_expression
	: postfix_expression
//	| INC_OP unary_expression
//	| DEC_OP unary_expression
//	| unary_operator cast_expression
//	| SIZEOF unary_expression
//	| SIZEOF '(' type_name ')'
	;

unary_operator
	: AMP
	| MULT
	| PLUS
	| MINUS
	| TILDE
	| EXCLAM
	;



primary_expression
    : IDENTIFIER {
        $$ = std::make_shared<Variable>($1);
    }
    | CONSTANT {
        $$ = std::make_shared<NumberLiteral>($1);
    }
    | STRING_LITERAL {
        $$ = std::make_shared<StringLiteral>($1);
    }
    | LPAREN expression RPAREN {
        $$ = $2;
    }
    ;

expression
	: assignment_expression
	| expression COMMA assignment_expression
	;


postfix_expression
	: primary_expression
//	| postfix_expression '[' expression ']'
//	| postfix_expression '(' ')'
//	| postfix_expression '(' argument_expression_list ')'
//	| postfix_expression '.' IDENTIFIER
//	| postfix_expression PTR_OP IDENTIFIER
//	| postfix_expression INC_OP
//	| postfix_expression DEC_OP
//	| '(' type_name ')' '{' initializer_list '}'
//	| '(' type_name ')' '{' initializer_list ',' '}'
	;


assignment_operator
    : ASSIGN
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | LEFT_ASSIGN
    | RIGHT_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    | OR_ASSIGN
    ;




translation_unit
    : external_declaration  {
        $$ = std::make_shared<TranslationUnit>();
        for(const auto& item_declaration : $1) { // external_declaration and declaration is std::vector becouse of "int a = 1, b = 2;" declarations like this
            $$->addChild(item_declaration);
        }
        driver.m_root = $$;
    }
    | translation_unit external_declaration {
        for(const auto& item_declaration : $2) {
            $1->addChild(item_declaration);
        }
        $$ = $1;
    }
    ;



external_declaration
    : declaration
    | function_definition {
        $$ = {$1};
    }
    ;


declaration
	: declaration_specifiers init_declarator_list SEMICOLON {
        // Getting variable type
	    std::string type = $1->getTypeAsString();

        for(const auto& init_decl : $2) {
            std::shared_ptr<Declaration> decl;
            // Getting variable name
            std::string name = init_decl->declarator->getName();

            // Getting initializer
            std::string value = init_decl->initializer->getValue();

            decl = std::make_shared<VarDecl>(type, name);

            decl->inner.push_back(init_decl->initializer);
            $$.push_back(decl);
        }
	}
//	| declaration_specifiers SEMICOLON
	;


function_definition
	: declaration_specifiers declarator compound_statement {
        const auto& declSpec = $1;
        const auto& returnType = declSpec->getTypeAsString();
        const auto& declarator = $2;
        const auto& body = $3;
        $$ = std::make_shared<FunctionDecl>(
            returnType, declarator->getName(), declarator->parameters, body
        );
	}
    ;



// add function
declaration_specifiers
    : storage_class_specifier {
        $$ = std::make_shared<DeclSpec>();
        $$->storage.push_back($1);
    }
    | storage_class_specifier declaration_specifiers {
        $$ = $2;
        $$->storage.push_back($1);
    }
    | type_specifier {
        $$ = std::make_shared<DeclSpec>();
        $$->typeSpec = $1;
    }
    | type_specifier declaration_specifiers {
        $$ = $2;
        $$->typeSpec = $1;
    }
    | type_qualifier {
        $$ = std::make_shared<DeclSpec>();
        $$->typeQuals.push_back($1);
    }
    | type_qualifier declaration_specifiers {
        $$ = $2;
        $$->typeQuals.push_back($1);
    }
    ;

direct_declarator
    : IDENTIFIER {
        $$ = std::make_shared<Declarator>($1);
    }
    | LPAREN declarator RPAREN {
        $$ = $2;
    }
//    | direct_declarator LPAREN parameter_type_list RPAREN {
//        $$ = $1;
//        $$->isFunction = true;
//        $$->parameters = $3;
//    }
    | direct_declarator LPAREN RPAREN {
        $$ = $1;
        $$->isFunction = true;
    }

//    | direct_declarator LBRACKET assignment_expression RBRACKET {
//        $$ = $1;
//        $$->isArray = true;
//    }

//    | direct_declarator LBRACKET RBRACKET {
//        $$ = $1;
//        $$->isArray = true;
//    }
    ;

compound_statement
	: LBRACE RBRACE {
	    $$ = std::make_shared<CompoundStmt>(
	    );
	}
	| LBRACE block_item_list RBRACE {
	    $$ = std::make_shared<CompoundStmt>($2);
	}
	;

block_item_list
	: block_item {
	    $$.push_back($1);
	}
	| block_item_list block_item {
	    $$ = $1;
	    $$.push_back($2);
	}
	;

block_item
    : declaration {
        $$ = $1[0];
    }
    //| statement {
      //  $$ = std::make_shared<Statement>();
    //}
    ;

declarator
// pointer
    : direct_declarator
    ;


init_declarator_list
	: init_declarator {
	    $$ = {$1};
	}
	| init_declarator_list COMMA init_declarator {
        $1.push_back($3);
        $$ = $1;
	}
	;

init_declarator
	: declarator {
	    $$ = std::make_shared<InitDeclarator>($1);
	}
	| declarator ASSIGN initializer {
	    $$ = std::make_shared<InitDeclarator>($1, $3);
	}
	;


initializer
	: assignment_expression
//	| '{' initializer_list '}'
//	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| initializer_list COMMA initializer
	;

storage_class_specifier
    : TYPEDEF   { $$ = "typedef"; }
    | EXTERN    { $$ = "extern"; }
    | STATIC    { $$ = "static"; }
    | AUTO      { $$ = "auto"; }
    ;


type_specifier
    : VOID      { $$ = "void"; }
    | CHAR      { $$ = "char"; }
    | SHORT     { $$ = "short"; }
    | INT       { $$ = "int"; }
    | LONG      { $$ = "long"; }
    | FLOAT     { $$ = "float"; }
    | DOUBLE    { $$ = "double"; }
    | UNSIGNED  { $$ = "unsigned"; }
    ;

type_qualifier
	: CONST { $$ = "const"; }
	| VOLATILE { $$ = "volatile"; }
	;





%%


void parser::Parser::error(const location &loc , const std::string &message) {

        // Location should be initialized inside scanner action, but is not in this example.
        // Let's grab location directly from driver class.
	// cout << "Error: " << message << endl << "Location: " << loc << endl;

        cout << "Error: " << message << endl << "Error location: " << driver.location() << endl;
}