(begin
  (set! i 10)
  (loop
    (if (= i 0) (return i))
    (set! i (- i 1))
    (vim-do "
      echo 'count down' a:1
      redraw
      sleep 1
    " i)
  )
  (vim-echo "bomb!")
)

;; vim: set ft=lisp:
