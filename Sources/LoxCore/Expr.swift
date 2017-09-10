
protocol ExprVisitor {

    associatedtype ExprVisitorReturn

    func visitAssignExpr(_ expr: Expr.Assign) -> ExprVisitorReturn
    func visitBinaryExpr(_ expr: Expr.Binary) -> ExprVisitorReturn
    func visitCallExpr(_ expr: Expr.Call) -> ExprVisitorReturn
    func visitFunctionExpr(_ expr: Expr.Function) -> ExprVisitorReturn
    func visitGroupingExpr(_ expr: Expr.Grouping) -> ExprVisitorReturn
    func visitLiteralExpr(_ expr: Expr.Literal) -> ExprVisitorReturn
    func visitLogicalExpr(_ expr: Expr.Logical) -> ExprVisitorReturn
    func visitUnaryExpr(_ expr: Expr.Unary) -> ExprVisitorReturn
    func visitVariableExpr(_ expr: Expr.Variable) -> ExprVisitorReturn
}

class Expr {

    func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
        fatalError()
    }

    class Assign: Expr {
        let name: Token
        let value: Expr

        init(name: Token, value: Expr) {
            self.name = name
            self.value = value
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitAssignExpr(self)
        }
    }

    class Binary: Expr {
        let left: Expr
        let op: Token
        let right: Expr

        init(left: Expr, op: Token, right: Expr) {
            self.left = left
            self.op = op
            self.right = right
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitBinaryExpr(self)
        }
    }

    class Call: Expr {
        let callee: Expr
        let paren: Token
        let arguments: Array<Expr>

        init(callee: Expr, paren: Token, arguments: Array<Expr>) {
            self.callee = callee
            self.paren = paren
            self.arguments = arguments
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitCallExpr(self)
        }
    }

    class Function: Expr {
        let parameters: Array<Token>
        let body: Array<Stmt>

        init(parameters: Array<Token>, body: Array<Stmt>) {
            self.parameters = parameters
            self.body = body
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitFunctionExpr(self)
        }
    }

    class Grouping: Expr {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitGroupingExpr(self)
        }
    }

    class Literal: Expr {
        let value: Any?

        init(value: Any?) {
            self.value = value
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitLiteralExpr(self)
        }
    }

    class Logical: Expr {
        let left: Expr
        let op: Token
        let right: Expr

        init(left: Expr, op: Token, right: Expr) {
            self.left = left
            self.op = op
            self.right = right
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitLogicalExpr(self)
        }
    }

    class Unary: Expr {
        let op: Token
        let right: Expr

        init(op: Token, right: Expr) {
            self.op = op
            self.right = right
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitUnaryExpr(self)
        }
    }

    class Variable: Expr {
        let name: Token

        init(name: Token) {
            self.name = name
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitVariableExpr(self)
        }
    }
}
