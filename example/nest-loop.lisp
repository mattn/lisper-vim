(begin
  (set! i 10)
  (loop
	(if (= i 0) (return i))
	(vim-echo "i" i)
    (set! j 10)
    (loop
	  (vim-echo "j" j)
	  (if (= j 0) (return j))
	  (set! j (- j 1))
    )
	(set! i (- i 1))
  )
)
