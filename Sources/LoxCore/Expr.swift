
protocol ExprVisitor {
    associatedtype ExprVisitorReturn

    func visitAssignExpr(_ expr: Expr.Assign) -> ExprVisitorReturn
    func visitBinaryExpr(_ expr: Expr.Binary) -> ExprVisitorReturn
    func visitCallExpr(_ expr: Expr.Call) -> ExprVisitorReturn
    func visitGetExpr(_ expr: Expr.Get) -> ExprVisitorReturn
    func visitGroupingExpr(_ expr: Expr.Grouping) -> ExprVisitorReturn
    func visitLiteralExpr(_ expr: Expr.Literal) -> ExprVisitorReturn
    func visitLogicalExpr(_ expr: Expr.Logical) -> ExprVisitorReturn
    func visitSetExpr(_ expr: Expr.Set) -> ExprVisitorReturn
    func visitSuperExpr(_ expr: Expr.Super) -> ExprVisitorReturn
    func visitThisExpr(_ expr: Expr.This) -> ExprVisitorReturn
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

    class Get: Expr {
        let object: Expr
        let name: Token

        init(object: Expr, name: Token) {
            self.object = object
            self.name = name
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitGetExpr(self)
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

    class Set: Expr {
        let object: Expr
        let name: Token
        let value: Expr

        init(object: Expr, name: Token, value: Expr) {
            self.object = object
            self.name = name
            self.value = value
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitSetExpr(self)
        }
    }

    class Super: Expr {
        let keyword: Token
        let method: Token

        init(keyword: Token, method: Token) {
            self.keyword = keyword
            self.method = method
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitSuperExpr(self)
        }
    }

    class This: Expr {
        let keyword: Token

        init(keyword: Token) {
            self.keyword = keyword
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.ExprVisitorReturn {
            return visitor.visitThisExpr(self)
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
