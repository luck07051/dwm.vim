
if exists("g:loaded_dwm") || &diff || &cp
  finish
endif
let g:loaded_dwm = 1

" set splitbelow

" TODO
"   bug report for `win_splitmove()`
"
"   push stack (mod+shift+{j, k})
"   rotate
"
"   command line, quickfix without relayout
"   fix layout when window close or new
"
"   attachbottom (when splitbelow or splitright)
"   new tab
"   dwm_n_master tab support


" Init {{{
let s:dwm_n_master = 1

if !exists('g:dwm_width')
  let s:dwm_width = repeat([(&columns)/2], tabpagenr('$'))
else
  let s:dwm_width = repeat([g:dwm_width], tabpagenr('$'))
endif
" }}}

" Function {{{
" Move the current layout to Stack.
function! s:dwm_2stack()
  for i in range(winnr('$')-1)
    call win_splitmove(i+2, i+1)
    call win_splitmove(i+2, i+1)
  endfor
endfunction

" Move the Stack layout to Master layout.
function! s:dwm_2master()
  " move the first window to topleft.
  let l:curwin = winnr()
  wincmd t
  wincmd H
  exe l:curwin .. "wincmd w"

  " move the remaining windows to master stack.
  let l:leftnr = s:dwm_n_master-1
  if l:leftnr > 0
    for i in range(l:leftnr)
      call win_splitmove(i+2, i+1)
      call win_splitmove(i+2, i+1)
    endfor
  endif

  call s:dwm_resize()
endfunction

" Resize the width.
function! s:dwm_resize()
  wincmd =
  call win_move_separator(1, s:dwm_width[tabpagenr()-1] - winwidth(1))
endfunction
" }}}

" Change the focus.
" Highly recommend using <C-W>w and <C-W>W directly.
function! dwm#focus(i)
  if a:i == 0
    return
  elseif a:i > 0
    for _ in range(a:i)
      wincmd w
    endfor
  else
    for _ in range(-a:i)
      wincmd W
    endfor
  endif
endfunction

function! dwm#quit()
  quit
  " call s:dwm_2stack()
  " call s:dwm_2master()
endfunction



" Move the current window to top of stack.
function! dwm#zoom()
  if winnr('$') == 1
    return
  endif
  " if current window is master, move second winow to top.
  if winnr() <= s:dwm_n_master
    wincmd w
  endif

  call s:dwm_2stack()
  wincmd K  " move focused window to top of stack.
  call s:dwm_2master()
endfunction

" Increase the width of the master window.
function! dwm#incwidth(i)
  let l:curtab = tabpagenr() - 1

  let s:dwm_width[l:curtab] += a:i
  if s:dwm_width[l:curtab] < &winminwidth
    let s:dwm_width[l:curtab] = &winminwidth
  elseif s:dwm_width[l:curtab] > &columns
    let s:dwm_width[l:curtab] = &columns
  endif

  call win_move_separator(1, a:i)
endfunction

" Increase the number of master stack,
" like default keybindings of mod+i and mod+d on dwm.
function! dwm#incnmaster(i)
  let s:dwm_n_master += a:i
  if s:dwm_n_master < 1
    let s:dwm_n_master = 1
  elseif s:dwm_n_master > winnr('$')
    let s:dwm_n_master = winnr('$')
  endif

  call s:dwm_2stack()
  call s:dwm_2master()
endfunction



let s:cur_win_nr = winnr('$')
function! s:dwm_fixlayout_new()
  " &buftype and & filetype will print out current file type
  " instead of new file type.

  if winnr('$') == s:cur_win_nr
    return
  endif

  if winnr('$') > s:cur_win_nr
    wincmd H
  endif

  call s:dwm_2stack()
  call s:dwm_2master()
endfunction

augroup dwm
  au!
  au WinNew * call s:dwm_fixlayout_new()
augroup end



" nnoremap <silent> <Plug>DwmNew        :call dwm#new()<CR>
nnoremap <silent> <Plug>DwmNew        :vertical new<CR>
nnoremap <silent> <Plug>DwmQuit       :call dwm#quit()<CR>
nnoremap <silent> <Plug>DwmFocusUp    <C-W>w
nnoremap <silent> <Plug>DwmFocusDown  <C-W>W
nnoremap <silent> <Plug>DwmIncWidth   :call dwm#incwidth(+3)<CR>
nnoremap <silent> <Plug>DwmDecWidth   :call dwm#incwidth(-3)<CR>
nnoremap <silent> <Plug>DwmZoom       :call dwm#zoom()<CR>
nnoremap <silent> <Plug>DwmIncNMaster :call dwm#incnmaster(+1)<CR>
nnoremap <silent> <Plug>DwmDecNMaster :call dwm#incnmaster(-1)<CR>

if !exists("g:dwm_no_mappings") || !g:dwm_no_mappings
  nmap <M-j> <Plug>DwmFocusUp
  nmap <M-k> <Plug>DwmFocusDown
  nmap <M-l> <Plug>DwmIncWidth
  nmap <M-h> <Plug>DwmDecWidth
  nmap <M-Return> <Plug>DwmNew
  nmap <M-q> <Plug>DwmQuit
  nmap <M-m> <Plug>DwmZoom
  nmap <M-i> <Plug>DwmIncNMaster
  nmap <M-d> <Plug>DwmDecNMaster


  tmap <M-j> <C-\><C-n><C-W>w
  tmap <M-k> <C-\><C-n><C-W>W
  tmap <M-l> <C-\><C-n>:call dwm#incwidth(+3)<CR>
  tmap <M-h> <C-\><C-n>:call dwm#incwidth(-3)<CR>
  tmap <M-m> <C-\><C-n>:call dwm#zoom()<CR>

  " nnoremap <silent> <Leader>t :call dwm#terminal_b()<CR>
endif
