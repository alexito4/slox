
class Expr {

    class Binary: Expr {
        let left: Expr
        let op: Token
        let right: Expr

        init(left: Expr, op: Token, right: Expr) {
            self.left = left
            self.op = op
            self.right = right
        }
    }

    class Grouping: Expr {
        let expression: Expr

        init(expression: Expr) {
            self.expression = expression
        }
    }

    class Literal: Expr {
        let value: Any

        init(value: Any) {
            self.value = value
        }
    }

    class Unary: Expr {
        let op: Token
        let right: Expr

        init(op: Token, right: Expr) {
            self.op = op
            self.right = right
        }
    }

}
