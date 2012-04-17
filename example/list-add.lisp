(define list-map (lambda (lhs rhs) (vim-call "map" lhs rhs)))
(define list-add (lambda (lhs rhs) (vim-call "add" lhs rhs)))
(set! l (quote (1 2 3)))
(list-add l 4)
(list-add l 5)
(list-add l 6)
(list-map l "'foo'.v:val")

;; vim: set ft=lisp:
