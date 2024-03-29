if exists ("g:loaded_auctoribus_autoload")
  finish
else
  let g:loaded_auctoribus_autoload=1

"Initialize counters"
let b:auctoribus_words = 0
let b:auctoribus_bytes = 0
let b:auctoribus_sentences = 0
let b:auctoribus_reading_time  = 0
let b:auctoribus_speaking_time = 0
let b:auctoribus_ari = 0
let b:auctoribus_clf = 0

"Set defaults"
if !exists("g:auctoribus_reading_rate")
  let g:auctoribus_reading_rate  = 175
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
if !exists("g:auctoribus_sentence_goal")
  let g:auctoribus_sentence_goal = 1000
endif
if !exists("g:auctoribus_speaking_goal")
  let g:auctoribus_speaking_goal = 60
endif
if !exists("g:auctoribus_reading_goal")
  let g:auctoribus_reading_goal = 60
endif
if !exists("g:auctoribus_ari_goal")
  let g:auctoribus_ari_goal = 10.0
endif
if !exists("g:auctoribus_clf_goal")
  let g:auctoribus_clf_goal = 12.0
endif
if !exists("g:auctoribus_goal")
  let g:auctoribus_goal = 1
endif
if !exists("g:auctoribus_theme_litfg")
  let g:auctoribus_theme_litfg='yellow'
endif
if !exists("g:auctoribus_theme_litbg")
  let g:auctoribus_theme_litbg='darkblue'
endif
if !exists("g:auctoribus_theme_unlitfg")
  let g:auctoribus_theme_unlitfg='gray'
endif
if !exists("g:auctoribus_theme_unlitbg")
  let g:auctoribus_theme_unlitbg='black'
endif
if !exists("g:auctoribus")
  let g:auctoribus = 0
endif

command! -nargs=+ Hi call CustomHighlighter(<f-args>)
function! CustomHighlighter(name, ...)
    let l:colour_order = ['ctermfg', 'ctermbg', 'guifg', 'guibg']
    let l:command = 'hi ' . a:name
    if (len(a:000) < 1) || (len(a:000) > (len(l:colour_order)))
        echoerr "No colour or too many colours specified"
    else
        for i in range(0,len(a:000)-1)
            let l:command .= ' ' . l:colour_order[i] . '=' . a:000[i]
        endfor
        let l:command .= ' cterm=reverse,bold gui=none'
        exe l:command 
    endif
endfunc 

exe 'Hi' 'StatusLineLit' g:auctoribus_theme_litfg g:auctoribus_theme_litbg g:auctoribus_theme_litfg g:auctoribus_theme_litbg
exe 'Hi' 'StatusLineUnlit' g:auctoribus_theme_unlitfg g:auctoribus_theme_unlitbg g:auctoribus_theme_unlitfg g:auctoribus_theme_unlitbg


function! auctoribus#CountSentences()
  return eval(join(map(range(1, line('$')), 'len(split(getline(v:val), "[.!?][])\042\047]*\\($\\|[ ]\\)", 1)) - 1')," + "))
endfunction auctoribus#CountSentences

function! auctoribus#CountChars()
  return eval(join(map(range(1, line('$')), 'len(substitute(getline(v:val), "[^[:alnum:][:punct:]]","","g"))')," + "))
endfunction auctoribus#CountChars

function! auctoribus#Count () 
  let s:old_status = v:statusmsg
  let position = getpos(".")
  exe "silent normal g\<c-g>"
  let l:stat = v:statusmsg
  let l:word_count = 0
  let l:chars_count = 0
  let l:sentence_count = 0
  if l:stat != '--No lines in buffer--'
    let l:word_count = str2nr(split(v:statusmsg)[11])
    "let l:chars_count = str2nr(split(v:statusmsg)[15])
    let l:chars_count = auctoribus#CountChars()
    let l:sentence_count = auctoribus#CountSentences()
    let v:statusmsg = s:old_status
  end
  call setpos('.', position)
  return [l:word_count, l:chars_count, l:sentence_count]
endfunction auctoribus#Count

function! auctoribus#ARI (letters, words, sentences)
  return string(4.71*(a:letters/a:words)+0.5*(a:words/a:sentences)-21.43)
endfunction auctoribus#ARI

function! auctoribus#CLF (letters, words, sentences)
  return string(5.879851*(a:letters/a:words)-29.587280*(a:sentences/a:words)-15.800804)
endfunction auctoribus#CLF

function! auctoribus#UpdateCount ()
  let l:counters = auctoribus#Count()
  let b:auctoribus_words = l:counters[0]
  let b:auctoribus_bytes = l:counters[1]
  let b:auctoribus_sentences = l:counters[2]
  let b:auctoribus_reading_time  = b:auctoribus_words / g:auctoribus_reading_rate
  let b:auctoribus_speaking_time = b:auctoribus_words / g:auctoribus_speaking_rate

  "Update Readability Metrics"
  let b:auctoribus_ari = auctoribus#ARI(b:auctoribus_bytes, b:auctoribus_words, b:auctoribus_sentences)
  let b:auctoribus_clf = auctoribus#CLF(b:auctoribus_bytes, b:auctoribus_words, b:auctoribus_sentences)

  if exists("g:auctoribus_goal") && g:auctoribus_goal>0
    if exists("g:auctoribus_word_goal") || exists("g:auctoribus_char_goal") || ("g:auctoribus_speaking_goal") || exists("g:auctoribus_reading_goal") || exists("g:auctoribus_ari_goal") || exists("g:auctoribus_clf_goal") || exists("g:auctoribus_sentence_goal")
      " Make StatusLine light up if the author reached production, delivery, and readability goals. At least one goal per category need to be reached."

      if (b:auctoribus_words>g:auctoribus_word_goal || b:auctoribus_bytes>g:auctoribus_char_goal || b:auctoribus_sentences>g:auctoribus_sentence_goal) && (b:auctoribus_reading_time>g:auctoribus_reading_goal || b:auctoribus_speaking_time>g:auctoribus_speaking_goal) && (b:auctoribus_ari<g:auctoribus_ari_goal || b:auctoribus_clf<g:auctoribus_clf_goal)
        hi clear StatusLine | hi link StatusLine StatusLineLit
      else
        hi clear StatusLine | hi link StatusLine StatusLineUnlit
      endif
    endif
  endif

endfunction auctoribus#UpdateCount

if exists("g:auctoribus") && g:auctoribus>0
   "Update Auctoribus counters when relevant events are fired"

   augroup auctoribus#countergroup
      autocmd!
      autocmd CursorHold,CursorHoldI,FileChangedShellPost,InsertLeave * call auctoribus#UpdateCount()
   augroup END
   set updatetime=700
endif

endif

" Set the status line as you deem more useful to you.
" b:auctoribus_words is the word counter
" b:auctoribus_bytes is the byte counter
" b:auctoribus_sentences is the sentences counter
" b:auctoribus_ari is the Automated Readablity Index (ARI) score
" b:auctoribus_clf is the score for the Coleman-Liau Formula
" b:auctoribus_reading_time is the estimated reading time at g:auctoribus_reading_rate reading rate
" b:auctoribus_speaking_time is the estimated speaking time at g:auctoribus_speaking_rate reading rate
"
" Writing goals (words, characters, number of sentences, reading minutes, speaking minutes, Automated Readability Index score, Coleman-Liau Index score) are defined in:
" Production goals:
" g:auctoribus_word_goal 
" g:auctoribus_char_goal 
" g:auctoribus_sentence_goal 
"
" Delivery goals:
" g:auctoribus_reading_goal 
" g:auctoribus_speaking_goal 
"
" Readability goals:
" g:auctoribus_ari_goal 
" g:auctoribus_clf_goal 
"
" Example:
" :set statusline=%{b:auctoribus_words}\ words\ \ %{b:auctoribus_bytes}\ chars
" :set statusline=%{b:auctoribus_words}\ words\ \ %{b:auctoribus_bytes}\ chars\ \ speaking:\ %{b:auctoribus_speaking_time}\ mins\ \ reading:\ %{b:auctoribus_reading_time}\ mins
" :set statusline=%{b:auctoribus_words}/%{g:auctoribus_word_goal}\ words\ \ %{b:auctoribus_bytes}/%{g:auctoribus_char_goal}\ chars\ \ %{b:auctoribus_speaking_time }/%{g:auctoribus_speaking_goal}\ mins\ speaking\ \ %{b:auctoribus_reading_time}/%{g:auctoribus_reading_goal}\ mins\ reading
" :set statusline=%{b:auctoribus_words}\ words\ \ %{b:auctoribus_bytes}\ chars\ \ \ %{b:auctoribus_sentences} sentences
" :set statusline=%{b:auctoribus_words}\ words\ \ %{b:auctoribus_bytes}\ chars\ \ ARI:\ %{b:auctoribus_ari}\ Coleman-Liau:\ %{b:auctoriubs_clf}
