;; extends

(binary_operator
  lhs: (_)
  operator: "<-"
  rhs: (_)) @indent.begin

(if (call)) @indent.begin

(if (binary_operator)) @indent.begin

(if (identifier)) @indent.begin

(if (for)) @indent.begin

(for (if)) @indent.begin

(for (call)) @indent.begin

(for (for)) @indent.begin

(for (binary_operator)) @indent.begin
