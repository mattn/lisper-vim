(set! i 10)
(loop
  (if (= i 0) (return i))
  (print "i" i)
  (set! j 10)
  (loop
    (print "j" j)
    (if (= j 0) (return j))
    (set! j (- j 1))
  )
  (set! i (- i 1))
)

;; vim: set ft=lisp:
