if exists ("g:loaded_auctoribus_autoload")
  finish
else
  let g:loaded_auctoribus_autoload=1
  let g:auctoribus=1

"Initialize counters"
let g:auctoribus_words = 0
let g:auctoribus_bytes = 0
let g:auctoribus_reading_time  = 0
let g:auctoribus_speaking_time = 0

"Set defaults"
if !exists("g:auctoribus_reading_rate")
  let g:auctoribus_reading_rate  = 275
endif
if !exists("g:auctoribus_speaking_rate")
  let g:auctoribus_speaking_rate = 150
endif  
if !exists("g:auctoribus_word_goal")
  let g:auctoribus_word_goal = 15000
endif
if !exists("g:auctoribus_char_goal")
  let g:auctoribus_char_goal = 150000
endif
if !exists("g:auctoribus_speaking_goal")
  let g:auctoribus_speaking_goal = 60
endif
if !exists("g:auctoribus_reading_goal")
  let g:auctoribus_reading_goal = 60
endif


hi StatusLineLit   ctermfg=yellow ctermbg=darkblue cterm=reverse,bold gui=none guibg=yellow guifg=darkblue
hi StatusLineUnlit ctermfg=gray ctermbg=black     cterm=reverse,bold gui=none guibg=gray  guifg=black

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

  if exists("g:auctoribus_word_goal") || exists("g:auctoribus_char_goal") || ("g:auctoribus_speaking_goal") || exists("g:auctoribus_reading_goal")
    " Make StatusLine light up if the author reached one or more writing goals"

    if g:auctoribus_words>g:auctoribus_word_goal || g:auctoribus_bytes>g:auctoribus_char_goal || g:auctoribus_reading_time>g:auctoribus_reading_goal || g:auctoribus_speaking_time>g:auctoribus_speaking_goal
      hi clear StatusLine | hi link StatusLine StatusLineLit
    else
      hi clear StatusLine | hi link StatusLine StatusLineUnlit
    endif
  endif

endfunction s:auctoribus#UpdateCount

if exists("g:auctoribus") && g:auctoribus>0
   "Update Auctoribus counters when relevant events are fired"

   augroup auctoribus#countergroup
      autocmd!
      autocmd CursorHold,CursorHoldI,FileChangedShellPost,InsertLeave * call auctoribus#UpdateCount()
   augroup END
   set updatetime=700
endif

endif

" Set the status line as you please.
" g:auctoribus_words is the word counter
" g:auctoribus_bytes is the byte counter
" g:auctoribus_reading_time is the estimated reading time at g:auctoribus_reading_rate reading rate
" g:auctoribus_speaking_time is the estimated speaking time at g:auctoribus_speaking_rate reading rate
"
" Example:
" :set statusline=%{g:auctoribus_words}\ words\ \ %{g:auctoribus_bytes}\ chars
" :set statusline=%{g:auctoribus_words}\ words\ \ %{g:auctoribus_bytes}\ chars\ \ speaking:\ %{g:auctoribus_speaking_time}\ mins\ \ reading:\ %{g:auctoribus_reading_time}\ mins
" :set statusline=%{g:auctoribus_words}/%{g:auctoribus_word_goal}\ words\ \ %{g:au ctoribus_bytes}/%{g:auctoribus_char_goal}\ chars\ \ %{g:auctoribus_speaking_time }/%{g:auctoribus_speaking_goal}\ mins\ speaking\ \ %{g:auctoribus_reading_time}/%{g:auctoribus_reading_goal}\ mins\ reading
