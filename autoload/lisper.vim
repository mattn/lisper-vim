"=============================================================================
" lisper.vim
" Author: Yasuhiro Matsumoto <mattn.jp@gmail.com>
" Last Change: 18-Nov-2011.
"
" Based On: http://norvig.com/lis.py

let s:env = { "bind" : {} }

function! s:env.new(...)
  let params = a:0 > 0 ? a:000[0] : []
  let args   = a:0 > 1 ? a:000[1] : []
  let outer  = a:0 > 2 ? a:000[2] : 0
  let f = 0
  while f < len(params)
    let p = params[f]
    let m = type(p) == 4 ? p['_'] : p
    let self.bind[m] = args[f]
    let f += 1
  endwhile
  let self.outer = outer
  return deepcopy(self)
endfunction

function! s:env.find(...) dict
  let var = a:1
  let is_set = a:0 > 1 ? a:2 : 0
  if is_set || has_key(self.bind, var)
    return self.bind
  endif
  if !empty(self.outer) 
    return self.outer.find(var)
  endif
  throw "Not found symbol `".var."`"
endfunction

function! s:env.update(var) dict
  for k in keys(a:var)
    let self.bind[k] = a:var[k]
  endfor
endfunction

function! s:make_op(f, ...)
  let s:op_n = get(s:, 'op_n', 0) + 1
  let s:op_f{s:op_n}_ = a:f
  let s:op_f{s:op_n}__ = a:000
  function! s:op_f{s:op_n}(...)
    let __ = eval(substitute(expand('<sfile>'), '^.*\zeop_f[0-9]\+$', 's:', '').'__')
    return eval(eval(substitute(expand('<sfile>'), '^.*\zeop_f[0-9]\+$', 's:', '').'_'))
  endfunction
  return function('s:op_f'.s:op_n)
endfunction

function! s:debug(...)
  echohl WarningMsg | echomsg string(a:000) | echohl None
  return a:000
endfunction

function! s:add_globals(env)
  "env.update(vars(math)) # sin, sqrt, ...
  let env = a:env
  call env.update({
\ '+':       s:make_op('eval(join(map(range(a:0), ''"s:deref(a:".(v:val+1).")"''), ''+''))'),
\ '-':       s:make_op('eval(join(map(range(a:0), ''"s:deref(a:".(v:val+1).")"''), ''-''))'),
\ '*':       s:make_op('eval(join(map(range(a:0), ''"s:deref(a:".(v:val+1).")"''), ''*''))'),
\ '/':       s:make_op('eval(join(map(range(a:0), ''"s:deref(a:".(v:val+1).")"''), ''/''))'),
\ 'not':     s:make_op('!s:deref(a:1)'),
\ '>':       s:make_op('(s:deref(a:1) > s:deref(a:2))'),
\ '<':       s:make_op('(s:deref(a:1) < s:deref(a:2))'),
\ '>=':      s:make_op('(s:deref(a:1) >= s:deref(a:2))'),
\ '<=':      s:make_op('(s:deref(a:1) <= s:deref(a:2))'),
\ '=':       s:make_op('(s:deref(a:1) == s:deref(a:2))'),
\ 'equal?':  s:make_op('(s:deref(a:1) ==# s:deref(a:2))'),
\ 'eq?':     s:make_op('(s:deref(a:1) is# s:deref(a:2))'),
\ 'length':  s:make_op('len(s:deref(a:1))'),
\ 'cons':    s:make_op('s:deref(a:1).s:deref(a:2)'),
\ 'car':     s:make_op('s:deref(a:1)[0]'),
\ 'cdr':     s:make_op('s:deref(a:1)[1:]'),
\ 'append':  s:make_op('eval(join(map(map(copy(a:000), ''type(v:val)==3?v:val :[v:val]''), ''s:deref(v:val)''), ''+''))'),
\ 'list':    s:make_op('map(copy(a:000), ''s:deref(v:val)'')'),
\ 'list?':   s:make_op('type(s:deref(a:1))==3'),
\ 'null?':   s:make_op('len(s:deref(a:1)) == 0'),
\ 'symbol?': s:make_op('type(a:1) == 4'),
\})
  return env
endfunction

function! s:parse(s)
  let ctx = { "tokens": s:tokenize(a:s) }
  return s:read_from(ctx)
endfunction

function! s:tokenize(s)
  let s = a:s
  let s = substitute(s, '(', ' ( ', 'g')
  let s = substitute(s, ')', ' ) ', 'g')
  let ss = split(s, '\zs')
  let [n, l] = [0, len(ss)]
  let r = []
  while n < l
    let c = ss[n]
    if c == ' '
      let n += 1
    elseif c == '(' || c == ')'
      call add(r, c)
      let n += 1
    elseif c == '"'
      let b = c
      let n += 1
      while n < l
        let c = ss[n]
        if c == '"'
          let b .= c
          let n += 1
          break
        elseif c != '\'
          let b .= c
        endif
        let n += 1
      endwhile
      call add(r, b)
    else
      let b = ''
      while n < l
        let c = ss[n]
        if c == ' '
          break
        endif
        let n += 1
        let b .= c
      endwhile
      call add(r, b)
    endif
  endwhile
  return r
endfunction

function! s:read_from(ctx)
  if len(a:ctx.tokens) == 0
    throw 'unexpected EOF while reading'
  endif
  let token = a:ctx.tokens[0]
  let a:ctx.tokens = a:ctx.tokens[1:]
  if '(' == token
    let l = []
    while len(a:ctx.tokens) && a:ctx.tokens[0] != ')'
      call add(l, s:read_from(a:ctx))
    endwhile
    if len(a:ctx.tokens) == 0
      throw 'unexpected EOF while reading'
    endif
    let a:ctx.tokens = a:ctx.tokens[1:]
    return l
  elseif ')' == token
    throw 'unexpected )'
  else
    return s:atom(token)
  endif
endfunction

function! s:atom(token)
  let t = type(a:token)
  if t == 0 || t == 5
    return a:token
  elseif t == 1
    if a:token =~ '^[+-]\?[0-9]\+$'
      return 0 + a:token
    endif
    if a:token =~ '^\([+-]\?\)\%([0-9]\|\.[0-9]\)[0-9]*\(\.[0-9]*\)\?\([Ee]\([+-]\?[0-9]+\)\)\?$'
      return str2float(a:token)
    endif
    if a:token =~ '^\".*"$'
      return eval(a:token)
    endif
  endif
  return { "_" : a:token }
endfunction

function! lisper#stringer(v)
  let t = type(a:v)
  if t == 0 || t == 1 || t == 5
    return a:v
  elseif t == 4
    return lisper#stringer(a:v['_'])
  elseif t == 3
    let s = '('
    for V in a:v
      if s != '('
        let s .= ' '
      endif
      let s .= lisper#stringer(V)
      unlet V
    endfor
    let s .= ')'
    return s
  else
    return string(a:v)
  endif
endfunction

function! s:deref(x)
  return type(a:x) == 4 ? a:x['_'] : a:x
endfunction

let s:lisp = {}

function! s:lisp._eval(...) dict abort
  let x = a:1
  let env = a:0 > 1 ? a:2 : self.global_env
  if type(x) == 4 " symbol
    let s = x['_']
    return env.find(s)[s]
  elseif type(x) != 3 " constant
    return x
  else
    if len(x) == 0
      return
    endif
    let m = s:deref(x[0])
    if m == 'quote' " (quote exp)
      let [_, exp] = x
      return exp
    elseif m == 'if' " (if test conseq alt)
      let [_, test, conseq, alt] = x
      if self._eval(test, env)
        return self._eval(conseq, env)
      else
        return self._eval(alt, env)
      endif
    elseif m == 'set!' " (set! var exp)
      let [_, var, exp] = x
      let m = s:deref(var)
      let vars = env.find(m, 1)
      let vars[m] = self._eval(exp, env)
      return m
    elseif m == 'define' " (define var exp)
      let [_, var, exp] = x
      let m = s:deref(var)
      let env.bind[m] = self._eval(exp, env)
      return env.bind[m]
    elseif m == 'lambda' " (lambda (var*) exp)
      let [_, vars, exp] = x
      return {"_": s:make_op('__[0]._eval(__[1], s:env.new(__[2], a:000, __[3]))', self, exp, vars, env) }
    elseif m == 'begin' " (begin exp*)
      for exp in x[1:]
        silent! unlet val
        let val = self._eval(exp, env)
      endfor
      return val
    else " (proc exp*)
      let exps = []
      for exp in x
        call add(exps, self._eval(exp, env)) 
        unlet exp
      endfor
      return call(s:deref(exps[0]), exps[1:])
    endif
  endif
endfunction

function! s:lisp.eval(exp) dict
  return lisper#stringer(self._eval(s:parse(a:exp)))
endfunction

function! s:lisp.evalv(exp) dict
  return self._eval(s:parse(a:exp))
endfunction

function! lisper#engine()
  let engine = deepcopy(s:lisp)
  let engine.global_env = s:add_globals(s:env.new())
  return engine
endfunction

function! lisper#eval(exp)
  let engine = lisper#engine()
  try
    return engine.eval(a:exp)
  catch /.../
    let e = v:exception
    if e =~ '^Vim'
      let e = substitute(e, '^\S\+ ', '', '')
    endif
    throw e
  finally
    unlet engine
  endtry
endfunction

function! lisper#repl()
  let repl = lisper#engine()
  while 1
    let exp = input("lisp> ")
    echo "\n"
    if len(exp) > 0
      try
        let ret = repl.eval(exp)
        echohl Constant | echo "=>" ret | echohl None
      catch /.../
        echo v:exception
      endtry
    endif
  endwhile
endfunction
