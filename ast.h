#pragma once

#include <string>
#include <vector>
#include <memory>
#include <iostream>

#include "json.hpp"

using json = nlohmann::json;

enum class ASTNodeType {
    TranslationUnit,
    FunctionDecl,
    VarDecl,
	Declaration,
	Statement,
    BinaryOperator,
    UnaryExpr,
    NumberLiteral,
    StringLiteral,
    Identifier,
	ParamDecl,
    ReturnStmt,
    CompoundStmt,
};

static std::string ASTNodeTypeToString(ASTNodeType type) {
    switch(type) {
        case ASTNodeType::TranslationUnit: return "TranslationUnit";
        case ASTNodeType::FunctionDecl:    return "FunctionDecl";
        case ASTNodeType::VarDecl:         return "VarDecl";
        case ASTNodeType::Declaration:     return "Declaration";
        case ASTNodeType::Statement:       return "Statement";
        case ASTNodeType::BinaryOperator:  return "BinaryOperator";
        case ASTNodeType::UnaryExpr:       return "UnaryExpr";
        case ASTNodeType::NumberLiteral:   return "NumberLiteral";
        case ASTNodeType::StringLiteral:   return "StringLiteral";
        case ASTNodeType::Identifier:      return "Identifier";
        case ASTNodeType::ParamDecl:       return "ParamDecl";
        case ASTNodeType::ReturnStmt:      return "ReturnStmt";
        case ASTNodeType::CompoundStmt:    return "CompoundStmt";
        default: return "Unknown";
    }
}

class Declaration;



class ASTNode {
public:
    std::string kind;
    int line;
    std::vector<std::shared_ptr<ASTNode>> inner;

    ASTNode(ASTNodeType type, int line = -1) : kind(ASTNodeTypeToString(type)), line(line) {}
    virtual ~ASTNode() = default;

    virtual void print(int indent = 0) const = 0;
    virtual json toJson() const {}

};


class TranslationUnit : public ASTNode {
public:

    TranslationUnit(int line = -1) : ASTNode(ASTNodeType::TranslationUnit, line) {}

    void addChild(std::shared_ptr<ASTNode> extDecl) {
        inner.push_back(extDecl);
    }

    void print(int indent = 0) const override {
        std::cout << "TranslationUnit\n";
        for (auto& extDecl : inner)
            extDecl->print(indent + 2);
    }

    json toJson() const override {
        json j;
        j["kind"] = kind;
        j["line"] = line;
        j["inner"] = json::array();
        for (auto& child : inner) {
            j["inner"].push_back(child->toJson());
        }
        return j;
    }
};


class Expr : public ASTNode {
public:
    virtual void print(int indent = 0) const override {}
    virtual std::string getValue() const {}

    Expr(ASTNodeType type = ASTNodeType::NumberLiteral, int line = -1) : ASTNode(type, line) {}
};




class Identifier : public Expr {
public:
    std::string name;

    Identifier(const std::string& name, int line = -1)
        : Expr(ASTNodeType::Identifier, line), name(name) {}

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') << "Identifier(" << name << ")\n";
    }
};


class Statement : public ASTNode {
public:
    Statement(ASTNodeType type = ASTNodeType::Statement, int line = -1)
        : ASTNode(type, line) {}
	void print(int indent = 0) const override {}
    virtual ~Statement() = default;
};


class ReturnStmt : public Statement {
public:
    std::shared_ptr<Expr> expr;

    ReturnStmt(std::shared_ptr<Expr> expr, int line = -1)
        : Statement(ASTNodeType::ReturnStmt, line), expr(expr) {}

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') << "ReturnStmt\n";
        if (expr)
            expr->print(indent + 2);
    }
};

class CompoundStmt : public ASTNode {
public:

    CompoundStmt(const std::vector<std::shared_ptr<ASTNode>>& item_list = {}, int line = -1)
        : ASTNode(ASTNodeType::CompoundStmt, line) { inner = item_list; }

    void addChild(std::shared_ptr<ASTNode> item) {
        inner.push_back(item);
    }

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') << "CompoundStmt\n";
        for (const auto& item : inner)
            item->print(indent + 2);
    }
    json toJson() const override {
        json j;
        j["kind"] = kind;
        j["line"] = line;
        j["inner"] = json::array();
        for (auto& child : inner) {
            j["inner"].push_back(child->toJson());
        }
        return j;
    }

};







class NumberLiteral : public Expr {
public:
    std::string value;

    explicit NumberLiteral(const std::string& value, ASTNodeType type = ASTNodeType::NumberLiteral)
        : Expr(type, line), value(value) {}

    int toInt() const {
        try {
            return std::stoi(value, nullptr, 0);
        } catch (const std::exception& e) {
            throw std::runtime_error("Invalid integer literal: " + value);
        }
    }

    float toFloat() const {
        try {
            return std::stof(value);
        } catch (const std::exception& e) {
            throw std::runtime_error("Invalid float literal: " + value);
        }
    }

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') << "NumberLiteral(" << value << ")\n";
    }

    std::string getValue() const override {
		return value;
	}

    json toJson() const override {
        return {
            {"kind", kind},
            {"line", line},
            {"value", value},
            {"textLabel", value}
        };
    }

};


class StringLiteral : public Expr {
public:
    std::string value;

    explicit StringLiteral(const std::string& val, ASTNodeType type = ASTNodeType::StringLiteral)
        : Expr(type, line), value(val) {}

    json toJson() const override {
        json j = {
            {"kind", kind},
            {"line", line},
            {"value", value},
            {"textLabel", value}
        };
        return j;
    }

};


class Declaration : public ASTNode {
public:
    Declaration(ASTNodeType type = ASTNodeType::Declaration, int line = -1)
        : ASTNode(type, line) {}
	void print(int indent = 0) const override {}

    virtual ~Declaration() = default;
};


class VarDecl : public Declaration {
private:
    std::string type;
    std::string name;
    std::shared_ptr<Expr> initializer;

public:
    VarDecl(const std::string& type, const std::string& name,
                 std::shared_ptr<Expr> initializer = nullptr, int line = -1)
        : Declaration(ASTNodeType::VarDecl, line), type(type), name(name) {}

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') << "VarDecl(" << type << " " << name << ")\n";
        for (auto& item : inner)
            item->print(indent + 2);
    }

    json toJson() const override {
        json j;
        j["kind"] = kind;
        j["name"] = name;
        j["type"] = type;
        j["textLabel"] = name;
        j["inner"] = json::array();
        for (const auto& child : inner) {
            j["inner"].push_back(child->toJson());
        }
        return j;
    }
};



class ParamDecl : public Declaration {
public:
    bool isVariadic = false;
    std::string name;
    std::string type;

    ParamDecl(const std::string& type, const std::string& name, bool isVariadic = false, int line = -1)
        : Declaration(ASTNodeType::ParamDecl, line), name(name), type(type), isVariadic(isVariadic) {}

    std::string toString() const {
        if (isVariadic) return "...";
    }
};



class FunctionDecl : public Declaration {
private:
    std::string returnType;
    std::string name;
    std::vector<ParamDecl> paramDecls;
    std::shared_ptr<CompoundStmt> body;

public:
    FunctionDecl(const std::string& retType, const std::string& name, std::vector<std::shared_ptr<ParamDecl>> params,
                 std::shared_ptr<CompoundStmt> body, int line = -1)
        : Declaration(ASTNodeType::FunctionDecl, line), returnType(retType), name(name) {
            inner.push_back(body);
		}

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') << "FunctionDecl(" << returnType << " " << name << ")\n";
        if (body)
            body->print(indent + 2);
    }

    json toJson() const override {
        json j;
        j["kind"] = kind;
        j["line"] = line;
        j["textLabel"] = name;
        j["inner"] = json::array();
        for (auto& child : inner) {
            j["inner"].push_back(child->toJson());
        }
        return j;
    }
};


class BinaryOperator : public Expr {
private:
    std::string op;
    std::shared_ptr<Expr> lhs;
    std::shared_ptr<Expr> rhs;

public:
    BinaryOperator(const std::string& op,
                   std::shared_ptr<Expr> lhs,
                   std::shared_ptr<Expr> rhs,
                   int line = -1)
        : Expr(ASTNodeType::BinaryOperator, line),
          op(op), lhs(lhs), rhs(rhs) { inner = {lhs, rhs}; }

    void print(int indent = 0) const override {
        std::cout << std::string(indent, ' ') << "BinaryOperator(" << op << ")\n";
        if (lhs) lhs->print(indent + 2);
        if (rhs) rhs->print(indent + 2);
    }

    std::string getValue() const override {
        // Optional: For literal folding; just return empty for now
        return "";
    }
    json toJson() const override {
        json j = {
            {"kind", kind},
            {"line", line},
            {"op", op},
            {"textLabel", op}
        };
        j["inner"] = json::array();
        for (const auto& child : inner) {
            j["inner"].push_back(child->toJson());
        }
        return j;
    }
};

class Variable : public Expr {
public:
    std::string name;
    Variable(const std::string &n) : name(n) {}
};



class Parameter {
public:
    std::string name;
    std::string type;
    Parameter(const std::string& name, const std::string& type, int line = -1) : name(name), type(type) {}

};




class DeclSpec {
public:
    std::string typeSpec;                      // e.g., "int"
    std::vector<std::string> typeQuals;   // e.g., {"const"}
    std::vector<std::string> storage;      // e.g., {"static"}
    std::vector<std::string> funcSpecs;    // e.g., {"inline"}


public:
	std::string getTypeQualsAsString() const {
        return join(typeQuals);
    }

    std::string getStorageAsString() const {
        return join(storage);
    }

    std::string getFuncSpecsAsString() const {
        return join(funcSpecs);
    }

    std::string getTypeAsString() const {
        std::string result;

        result += getTypeQualsAsString();
        if (!result.empty() && !typeSpec.empty())
            result += " ";

        result += typeSpec;

        return result;
    }

private:
    static std::string join(const std::vector<std::string>& parts) {
        std::string result;
        for (const auto& part : parts) {
            if (!result.empty())
                result += " ";
            result += part;
        }
        return result;
    }
};



class Declarator {
public:
    std::string name;
    bool isPointer = false;
    bool isFunction = false;
    bool isArray = false;

    std::vector<std::shared_ptr<ParamDecl>> parameters; // for functions
    // std::shared_ptr<Declarator> inner; // for nested declarators (e.g., (*f)())

    Declarator(const std::string& name = "") : name(name) {}

    std::string getName() const {
        // if (inner) return inner->getName();
        return name;
    }


};


class InitDeclarator {
public:
    std::shared_ptr<Declarator> declarator;
    std::shared_ptr<Expr> initializer; // can be nullptr if no init

    InitDeclarator(std::shared_ptr<Declarator> declarator,
                   std::shared_ptr<Expr> initializer = nullptr)
        : declarator(declarator), initializer(initializer) {  }

    std::string getName() const {
        return declarator ? declarator->getName() : "";
    }

    bool hasInitializer() const {
        return initializer != nullptr;
    }
};

