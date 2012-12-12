if exists ("g:loaded_auctoribus_autoload")
  finish
else
  let g:loaded_auctoribus_autoload=1

let g:auctoribus_words = 0
let g:auctoribus_bytes = 0

function! auctoribus#Count () 
  let s:old_status = v:statusmsg
  let position = getpos(".")
  exe "silent normal g\<c-g>"
  let stat = v:statusmsg
  let s:word_count = 0
  let s:bytes_count = 0
  if stat != '--No lines in buffer--'
    let s:word_count = str2nr(split(v:statusmsg)[11])
    let s:bytes_count = str2nr(split(v:statusmsg)[15])
    let v:statusmsg = s:old_status
  end
  call setpos('.', position)
  return [s:word_count, s:bytes_count]
endfunction auctoribus#Count

function! auctoribus#UpdateCount ()
  let s:counters = auctoribus#Count()
  let g:auctoribus_words = s:counters[0]
  let g:auctoribus_bytes = s:counters[1]
endfunction s:auctoribus#UpdateCount

augroup auctoribus#counter
    autocmd!
    autocmd CursorHold,CursorHoldI,FileChangedShellPost,InsertLeave * call auctoribus#UpdateCount()
augroup END

endif

" Set the status line as you please.
" g:auctoribus_words is the word counter
" g:auctoribus_bytes is the byte counter
"
" Example:
" set statusline=%{g:auctoribus_words}\ words\ \ %{g:auctoribus_bytes}\ chars
