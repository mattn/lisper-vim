"=============================================================================
" File: lisper.vim
" Author: Yasuhiro Matsumoto <mattn.jp@gmail.com>
" Last Change: 18-Nov-2011.
" Version: 0.01
"
command! LisperRepl call lisper#repl()
command! LisperEvalLine echo lisper#eval(getline('.'))
command! LisperEvalBuffer echo lisper#eval(join(getline(1, '$'), "\n"))

" vim:set et:
