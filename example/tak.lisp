(begin
  (define tak (lambda (x y z)
    (if (<= x y)
        y
      (tak (tak (- 1 x) y z)
           (tak (- 1 y) z x)
           (tak (- 1 z) x y)))))
  (tak 12 16 0)
)
