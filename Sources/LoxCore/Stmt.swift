
protocol StmtVisitor {

    associatedtype Return

    func visitExpressionStmt(_ stmt: Stmt.Expression) -> Return
    func visitPrintStmt(_ stmt: Stmt.Print) -> Return
}

class Stmt {
    
    func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.Return {
        fatalError()
    }
    
    class Expression: Stmt {
        let expression: Expr
        
        init(expression: Expr) {
            self.expression = expression
        }
        
        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.Return {
            return visitor.visitExpressionStmt(self)
        }
    }
    
    class Print: Stmt {
        let expression: Expr
        
        init(expression: Expr) {
            self.expression = expression
        }
        
        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.Return {
            return visitor.visitPrintStmt(self)
        }
    }
    
}
