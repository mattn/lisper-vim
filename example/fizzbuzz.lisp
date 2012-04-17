(define i 0)
(loop
  (if (= i 100) (return i))
  (define i (+ i 1))
  (display (if (= (mod i 15) 0)
    "FizzBuzz" (if (= (mod i 5) 0)
      "Buzz" (if (= (mod i 3) 0)
        "Fizz" i))
  ))(newline)
)

;; vim: set ft=lisp et:
