(define http-get
  (lambda (url) (vim-eval "webapi#http#get(a:1).content" url))
)
(define from-utf8
  (lambda (str) (vim-call "iconv" str "utf-8" (vim-eval "&encoding")))
)
(define html-parse
  (lambda (html) (vim-eval "webapi#html#parse(a:1)" html))
)
(define html-to-text
  (lambda (dom) (vim-eval "wwwrenderer#render_dom(a:1)" dom))
)
(html-to-text
  (html-parse (from-utf8 (http-get "http://mattn.kaoriya.net/")))
)

;; vim: set ft=lisp et:
