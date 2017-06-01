
protocol StmtVisitor {

    associatedtype StmtVisitorReturn

    func visitExpressionStmt(_ stmt: Stmt.Expression) -> StmtVisitorReturn
    func visitPrintStmt(_ stmt: Stmt.Print) -> StmtVisitorReturn
}

class Stmt {
    
    func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.StmtVisitorReturn {
        fatalError()
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
    
}
