"=============================================================================
" File: lisper.vim
" Author: Yasuhiro Matsumoto <mattn.jp@gmail.com>
" Last Change: 03-Jul-2012.
" Version: 0.03
"
command! LisperRepl call lisper#repl()
command! LisperEvalLine echo lisper#eval(getline('.'))
command! -range=% LisperEvalBuffer echo lisper#eval("(begin\n".join(getline(<line1>, <line2>), "\n")."\n)")
command! -range=% LisperEvalBufferWithoutOutput call lisper#eval("(begin\n".join(getline(<line1>, <line2>), "\n")."\n)")
command! LisperVimBang call lisper#bang(expand('<sfile>'))|finish

" vim:set et:
