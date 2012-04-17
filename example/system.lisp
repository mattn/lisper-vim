(define system (vim-eval "function('system')"))
(system "ls -la ~/")
; or (vim-eval "system('ls')")
; or (vim-call "system" "ls")

;; vim: set ft=lisp:
