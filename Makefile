all: 
	bison -d -o parser.tab.cpp parser.y
	
	flex -o lexer.yy.cpp lexer.l
	
	g++ -std=c++17 -g -o parser interpreter.cpp main.cpp parser.tab.cpp lexer.yy.cpp

	
clean:
	rm -rf lexer.yy.cpp
	rm -rf parser.tab.cpp parser.tab.hpp location.hh position.hh stack.hh
	rm -rf parser
