
(begin
  (define system (vim-eval "function('system')"))
  (system "ls -la ~/")
  ; or (vim-eval "system('ls')")
)

;; vim: set ft=lisp:
