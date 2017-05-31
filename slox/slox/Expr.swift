
protocol Visitor {

    associatedtype Return

    // Decided to make the Visitor methods non-throwing to avoid polluting with throws
    // the visitors that don't return errors. Instead if an error has to be returnen
    // the specific visitor implementation will return a Result type.
    func visitBinaryExpr(_ expr: Expr.Binary) -> Return
    func visitGroupingExpr(_ expr: Expr.Grouping) -> Return
    func visitLiteralExpr(_ expr: Expr.Literal) -> Return
    func visitUnaryExpr(_ expr: Expr.Unary) -> Return
}

class Expr {

    func accept<V: Visitor, R>(visitor: V) -> R where R == V.Return {
        fatalError()
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

        override func accept<V: Visitor, R>(visitor: V) -> R where R == V.Return {
            return visitor.visitBinaryExpr(self)
        }
    }

    class Grouping: Expr {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: Visitor, R>(visitor: V) -> R where R == V.Return {
            return visitor.visitGroupingExpr(self)
        }
    }

    class Literal: Expr {
        let value: Any?

        init(value: Any?) {
            self.value = value
        }

        override func accept<V: Visitor, R>(visitor: V) -> R where R == V.Return {
            return visitor.visitLiteralExpr(self)
        }
    }

    class Unary: Expr {
        let op: Token
        let right: Expr

        init(op: Token, right: Expr) {
            self.op = op
            self.right = right
        }

        override func accept<V: Visitor, R>(visitor: V) -> R where R == V.Return {
            return visitor.visitUnaryExpr(self)
        }
    }
}
