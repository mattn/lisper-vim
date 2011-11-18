(begin
  (define http-get
    (lambda (url) (vim-eval "http#get(a:000[0])" url))
  )
  (set! res (http-get "http://www.google.com"))
  (vim-echo res)
)
;; vim: set ft=lisp:
