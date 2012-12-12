if exists ("g:loaded_auctoribus_autoload")
  finish
else
  let g:loaded_auctoribus_autoload=1

let g:auctoribus_words = 0
let g:auctoribus_bytes = 0
let g:auctoribus_reading_time  = 0
let g:auctoribus_speaking_time = 0

let g:auctoribus_reading_rate  = 275
let g:auctoribus_speaking_rate = 150

set updatetime=300

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
  let g:auctoribus_reading_time  = g:auctoribus_words / g:auctoribus_reading_rate
  let g:auctoribus_speaking_time = g:auctoribus_words / g:auctoribus_speaking_rate
endfunction s:auctoribus#UpdateCount

augroup auctoribus#countergroup
    autocmd!
    autocmd CursorHold,CursorHoldI,FileChangedShellPost,InsertLeave * call auctoribus#UpdateCount()
augroup END

endif

" Set the status line as you please.
" g:auctoribus_words is the word counter
" g:auctoribus_bytes is the byte counter
" g:auctoribus_reading_time is the estimated reading time at g:auctoribus_reading_rate reading rate
" g:auctoribus_speaking_time is the estimated speaking time at g:auctoribus_speaking_rate reading rate
"
" Example:
" set statusline=%{g:auctoribus_words}\ words\ \ %{g:auctoribus_bytes}\ chars
" :set statusline=%{g:auctoribus_words}\ words\ \ %{g:auctoribus_bytes}\ chars\ \ speaking:\ %{g:auctoribus_speaking_time}\ mins\ \ reading:\ %{g:auctoribus_reading_time}\ mins
