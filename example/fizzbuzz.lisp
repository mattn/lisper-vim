(begin
  (define FizzBuzz (lambda (n)
    (if (> n 1)
      (begin
        (vim-echo (FizzBuzz (- n 1)))
        (if (= (mod n 15) 0)
          "FizzBuzz" (if (= (mod n 5) 0)
            "Buzz" (if (= (mod n 3) 0)
              "Fizz" n))
        )
      ) 1))
  )
  (FizzBuzz 22)
)

;; vim: set ft=lisp et:
