" yupp - Browsing the origin of code generated by yupp lexical preprocessor
" Version: 0.0.2
" Copyright (c) 2016 Vitaly Kravtsov (in4lio@gmail.com)
" License: MIT license  {{{
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}

let s:STATE_SKIP      = -1
let s:STATE_NO_BROWSE = 0
let s:STATE_FRUIT     = 1
let s:STATE_ORIGIN    = 2

let s:file_state = {}
let s:file_jump  = {}
let s:file_data  = {}
let s:file_mtime = {}  " time of last modification

function! yupp#_switch_to(fn)
  if &modified
    " current buffer is modified
    return
  endif

  let n = bufnr(printf('^%s$', a:fn))
  if !buflisted(n)
    " open file
    edit `=fnamemodify(a:fn, ':.')`
  else
    " goto file buffer
    execute n 'buffer'
  endif
endfunction


function! yupp#browse()
  let fn = expand('%')
  if empty(fn)
    return
  endif

  if has_key(s:file_jump, fn)
    " familiar file
    let state = s:file_state[fn]

    if state == s:STATE_NO_BROWSE
      " switch between original file and fruit
      call yupp#_switch_to(s:file_jump[fn])

    elseif state == s:STATE_ORIGIN

    elseif state == s:STATE_FRUIT

    endif
    "!!!? cleanup
    return
  endif

  " unfamiliar file
  let s:file_state[fn] = s:STATE_SKIP

  if v:version >= 800
    " check browse (*.json)
    let fn_json = fn . '.json'

    if filereadable(fn_json)
      " browse file exists
      let s:file_data[fn] = json_decode(join(readfile(fn_json)))
      let s:file_state[fn] = s:STATE_FRUIT
      let s:file_mtime[fn] = getmtime(fn)
      return
    endif
  endif

  " check original file
  let b = fnamemodify(fn, ':r')
  let e = fnamemodify(fn, ':e')
  if empty(e) | return | endif

  if e == 'yugen'
    " *.yugen --> *.yu
    let origin = b . '.yu'  " or just b... (ignored)
  else
    let bb = fnamemodify(b, ':r')
    let be = fnamemodify(b, ':e')
    if be == 'yugen'
      " *.yugen.* --> *.*
      let origin = bb . '.' . e
    else
      " *.* --> *.yu-*
      let origin = b . '.yu-' . e
    endif
  endif

  if filereadable(origin)
    " original file exists
    let s:file_state[fn] = s:STATE_NO_BROWSE
    let s:file_jump[fn] = origin
    let s:file_state[origin] = s:STATE_NO_BROWSE
    let s:file_jump[origin] = fn
    call yupp#_switch_to(origin)
  endif
endfunction


function! yupp#cleanup()
  let fn = expand('%')
  if empty(fn)
    return
  endif

  if has_key(s:file_jump, fn)
    " familiar file
    let state = s:file_state[fn]

    if state == s:STATE_NO_BROWSE
      let kin = remove(s:file_jump, fn)
      call remove(s:file_jump, kin)
      call remove(s:file_state, fn)
      call remove(s:file_state, kin)

    elseif state == s:STATE_ORIGIN

    elseif state == s:STATE_FRUIT
      call remove(s:file_data, fn)
      call remove(s:file_state, fn)
      call remove(s:file_mtime, fn)
    endif
  endif
endfunction


function! yupp#reload()
  let fn = expand('<afile>')
  if empty(fn)
    return
  endif

  if has_key(s:file_jump, fn)
    " familiar file
    echom 'Changed ' . fn
  endif
endfunction

" vim: foldmethod=marker
