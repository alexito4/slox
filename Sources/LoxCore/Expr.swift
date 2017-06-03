
protocol ExprVisitor {

    // Different protocols with the same associatedtype name make it immposible to be conformed by the same type.
    // So I can't use just `Return` here or the Interpreter won't be able to implement Expr and Stmt visitors.
    associatedtype ExprVisitorReturn

    // Decided to make the Visitor methods non-throwing to avoid polluting with throws
    // the visitors that don't return errors. Instead if an error has to be returned
    // the specific visitor implementation will return a Result type.
    func visitAssignExpr(_ expr: Expr.Assign) -> ExprVisitorReturn
    func visitBinaryExpr(_ expr: Expr.Binary) -> ExprVisitorReturn
    func visitGroupingExpr(_ expr: Expr.Grouping) -> ExprVisitorReturn
    func visitLiteralExpr(_ expr: Expr.Literal) -> ExprVisitorReturn
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
