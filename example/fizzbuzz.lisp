(begin
  (set! i 0)
  (loop
    (if (= i 100) (return i))
    (set! i (+ i 1))
    (vim-echo (if (= (mod i 15) 0)
      "FizzBuzz" (if (= (mod i 5) 0)
        "Buzz" (if (= (mod i 3) 0)
          "Fizz" i))
    ))
  )
)

;; vim: set ft=lisp et:
