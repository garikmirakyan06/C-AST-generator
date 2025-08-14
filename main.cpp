#include <iostream>
#include <fstream>
#include "scanner.h"
#include "parser.tab.hpp"
#include "interpreter.h"
#include "ast.h"

#include "json.hpp"

using json = nlohmann::json;


int main(int argc, char **argv) {
    parser::Interpreter i;
    int res = i.parse();

    std::ofstream file("ast.json");
    json j = (*i.m_root).toJson();
    file << j.dump(2);

	std::cout << "Parse complete. Result = " << res << std::endl;


    return res;
}
