if exists ("g:loaded_auctoribus_autoload")
  finish
else
  let g:loaded_auctoribus_autoload=1
  let g:auctoribus=1

"Initialize counters"
let b:auctoribus_words = 0
let b:auctoribus_bytes = 0
let b:auctoribus_reading_time  = 0
let b:auctoribus_speaking_time = 0

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
  let l:word_count = 0
  let l:bytes_count = 0
  if stat != '--No lines in buffer--'
    let l:word_count = str2nr(split(v:statusmsg)[11])
    let l:bytes_count = str2nr(split(v:statusmsg)[15])
    let v:statusmsg = s:old_status
  end
  call setpos('.', position)
  return [l:word_count, l:bytes_count]
endfunction auctoribus#Count

function! auctoribus#UpdateCount ()
  let l:counters = auctoribus#Count()
  let b:auctoribus_words = l:counters[0]
  let b:auctoribus_bytes = l:counters[1]
  let b:auctoribus_reading_time  = b:auctoribus_words / g:auctoribus_reading_rate
  let b:auctoribus_speaking_time = b:auctoribus_words / g:auctoribus_speaking_rate

  if exists("g:auctoribus_word_goal") || exists("g:auctoribus_char_goal") || ("g:auctoribus_speaking_goal") || exists("g:auctoribus_reading_goal")
    " Make StatusLine light up if the author reached one or more writing goals"

    if b:auctoribus_words>g:auctoribus_word_goal || b:auctoribus_bytes>g:auctoribus_char_goal || b:auctoribus_reading_time>g:auctoribus_reading_goal || b:auctoribus_speaking_time>g:auctoribus_speaking_goal
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
" b:auctoribus_words is the word counter
" b:auctoribus_bytes is the byte counter
" b:auctoribus_reading_time is the estimated reading time at g:auctoribus_reading_rate reading rate
" b:auctoribus_speaking_time is the estimated speaking time at g:auctoribus_speaking_rate reading rate
"
" Example:
" :set statusline=%{b:auctoribus_words}\ words\ \ %{b:auctoribus_bytes}\ chars
" :set statusline=%{b:auctoribus_words}\ words\ \ %{b:auctoribus_bytes}\ chars\ \ speaking:\ %{b:auctoribus_speaking_time}\ mins\ \ reading:\ %{b:auctoribus_reading_time}\ mins
" :set statusline=%{b:auctoribus_words}/%{g:auctoribus_word_goal}\ words\ \ %{b:auctoribus_bytes}/%{g:auctoribus_char_goal}\ chars\ \ %{b:auctoribus_speaking_time }/%{g:auctoribus_speaking_goal}\ mins\ speaking\ \ %{b:auctoribus_reading_time}/%{g:auctoribus_reading_goal}\ mins\ reading
