
protocol StmtVisitor {

    associatedtype StmtVisitorReturn

    func visitBlockStmt(_ stmt: Stmt.Block) -> StmtVisitorReturn
    func visitBreakStmt(_ stmt: Stmt.Break) -> StmtVisitorReturn
    func visitExpressionStmt(_ stmt: Stmt.Expression) -> StmtVisitorReturn
    func visitFunctionStmt(_ stmt: Stmt.Function) -> StmtVisitorReturn
    func visitIfStmt(_ stmt: Stmt.If) -> StmtVisitorReturn
    func visitPrintStmt(_ stmt: Stmt.Print) -> StmtVisitorReturn
    func visitReturnStmt(_ stmt: Stmt.Return) -> StmtVisitorReturn
    func visitVarStmt(_ stmt: Stmt.Var) -> StmtVisitorReturn
    func visitWhileStmt(_ stmt: Stmt.While) -> StmtVisitorReturn
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

    class Break: Stmt {

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitBreakStmt(self)
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

    class Function: Stmt {
        let name: Token
        let parameters: Array<Token>
        let body: Array<Stmt>

        init(name: Token, parameters: Array<Token>, body: Array<Stmt>) {
            self.name = name
            self.parameters = parameters
            self.body = body
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitFunctionStmt(self)
        }
    }

    class If: Stmt {
        let condition: Expr
        let thenBranch: Stmt
        let elseBranch: Stmt?

        init(condition: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
            self.condition = condition
            self.thenBranch = thenBranch
            self.elseBranch = elseBranch
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitIfStmt(self)
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

    class Return: Stmt {
        let keyword: Token
        let value: Expr?

        init(keyword: Token, value: Expr?) {
            self.keyword = keyword
            self.value = value
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitReturnStmt(self)
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

    class While: Stmt {
        let condition: Expr
        let body: Stmt

        init(condition: Expr, body: Stmt) {
            self.condition = condition
            self.body = body
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
            return visitor.visitWhileStmt(self)
        }
    }
}
