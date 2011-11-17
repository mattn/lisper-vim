let s:engine = lisper#engine()

function! s:test_equal(lhs, rhs) abort
  let ret = s:engine.eval(a:lhs)
  echo a:lhs "=>" ret
  if ret !=# a:rhs
    throw "failed: expected =>".a:rhs
  endif
endfunction

function! s:test_lambda(lhs) abort
  let ret = s:engine.evalv(a:lhs)
  echo a:lhs "=>" lisper#stringer(ret)
  if type(ret) != 4
    throw "failed: expected => function ref"
  endif
endfunction

call s:test_equal("12345678", "12345678")
call s:test_equal("(quote 12345678)", "12345678")
call s:test_equal("(quote lispl)", "lispl")
call s:test_equal("(quote (a b c))", "(a b c)")
call s:test_equal("(+ 1 2 3 4 5 6 7 8 9 10)", "55")
call s:test_equal("(- 2 1 0)", "1")
call s:test_equal("(* 3 3 3)", "27")
call s:test_equal("(/ 50 5 10)", "1")
call s:test_equal("(not 0)", "1")
call s:test_equal("(> 1 2)", "0")
call s:test_equal("(< 3 1)", "0")
call s:test_equal("(>= 1 1)", "1")
call s:test_equal("(<= 2 2)", "1")
call s:test_equal("(= 10 10)", "1")
call s:test_equal("(equal? (quote aaa) (quote aaa))", "1")
call s:test_equal("(equal? 100 80)", "0")
call s:test_equal("(length (quote aaa))", "3")
call s:test_equal("(length (quote (a b c d e)))", "5")
call s:test_equal("(car (quote (a b)))", "a")
call s:test_equal("(cdr (quote (a b)))", "(b)")
call s:test_equal("(append (quote (a b)) (quote c) (quote d) (quote (e f)))", "(a b c d e f)")
call s:test_equal("(list 1 2 3 4 5 (quote (a b c)) 6 7 8 9 10)", "(1 2 3 4 5 (a b c) 6 7 8 9 10)")
call s:test_equal("(list? 1)", "0")
call s:test_equal("(list? (quote (1)))", "1")
call s:test_equal("(null? (quote ()))", "1")
call s:test_equal("(null? (quote (1)))", "0")
call s:test_equal("(null? 10)", "0")
call s:test_equal("(symbol? 10)", "0")
call s:test_equal("(symbol? (quote a))", "1")
call s:test_equal("(if (- 10 5) (quote then) (quote else))", "then")
call s:test_equal("(if 0 (quote then) (quote else))", "else")
call s:test_equal("(set! var (quote lispl))", "var")
call s:test_equal("var", "lispl")
call s:test_lambda("(define myadd (lambda (a b) (+ a b)))")
call s:test_equal("(myadd 10 20)", "30")
call s:test_equal("(begin (define mylist (lambda (a) (list var a))) (mylist var))", "(lispl lispl)")

" vi:set ts=8 sts=2 sw=2 tw=0:
