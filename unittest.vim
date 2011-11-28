scriptencoding utf-8

let s:engine = lisper#engine()

function! s:ss(s)
  if type(a:s) == 0 || type(a:s) == 5
    return string(a:s)
  endif
  let s = string(a:s)
  let s = substitute(s, '\n', '\\n', 'g')
  let s = substitute(s, '\r', '\\r', 'g')
  let s = substitute(s, '\t', '\\t', 'g')
  let s = substitute(s, "''", "'", 'g')
  if type(a:s) == 1
    let s = s[1:-2]
  endif
  return s
endfunction

function! s:test_equal(lhs, rhs) abort
  let ret = s:engine.eval(a:lhs)
  echo s:ss(a:lhs)."=>". s:ss(ret)
  if ret !=# a:rhs
    throw "failed: expected =>".s:ss(a:rhs)
  endif
endfunction

function! s:test_lambda(lhs) abort
  let ret = s:engine.evalv(a:lhs)
  echo a:lhs "=>" lisper#stringer(ret)
  if type(ret) != 4
    throw "failed: expected => function ref"
  endif
endfunction

try
  let s:more = &more
  set nomore
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
  call s:test_equal("(cons \"hello\t\" \",こんにちわ\" \"\n世界\")", "hello\t,こんにちわ\n世界")
  call s:test_equal("(sin 0.3)", sin(0.3))
  call s:test_equal("(cos 0.4)", cos(0.4))
  call s:test_equal("(tan 0.5)", tan(0.5))
  call s:test_equal("(asin 0.6)", asin(0.6))
  call s:test_equal("(acos 0.7)", acos(0.7))
  call s:test_equal("(atan 0.8)", atan(0.8))
  call s:test_equal("(atan2 0.8 0.9)", atan2(0.8, 0.9))
  call s:test_equal("(set! count 0)", "count")
  call s:test_equal("(loop (set! count (+ count 1)) (if (= 10 count) (return count)))", "10")
  call s:test_equal("((lambda var (+ (car var) (+ (car (cdr var)) 3))) 5 6)", "8")
  echohl Title | echo "SUCCEEDED" | echohl None
catch
  echohl WarningMsg | echo "FAILED: " v:exception | echohl None
finally
  let &more = s:more
endtry

" vi:set ts=8 sts=2 sw=2 tw=0:
