
protocol StmtVisitor {

    associatedtype StmtVisitorReturn

    func visitBlockStmt(_ stmt: Stmt.Block) -> StmtVisitorReturn
    func visitExpressionStmt(_ stmt: Stmt.Expression) -> StmtVisitorReturn
    func visitPrintStmt(_ stmt: Stmt.Print) -> StmtVisitorReturn
    func visitVarStmt(_ stmt: Stmt.Var) -> StmtVisitorReturn
}

class Stmt {

    func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
        fatalError()
    }

    class Block: Stmt {
        let statements: Array<Stmt>

        init(statements: Array<Stmt>) {
            self.statements = statements
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitBlockStmt(self)
        }
    }

    class Expression: Stmt {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitExpressionStmt(self)
        }
    }

    class Print: Stmt {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitPrintStmt(self)
        }
    }

    class Var: Stmt {
        let name: Token
        let initializer: Expr?

        init(name: Token, initializer: Expr?) {
            self.name = name
            self.initializer = initializer
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitVarStmt(self)
        }
    }
}
