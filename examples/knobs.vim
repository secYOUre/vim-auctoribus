let g:auctoribus = 1

let g:auctoribus_reading_rate  = 275
let g:auctoribus_speaking_rate = 150


let g:auctoribus_goal = 1

let g:auctoribus_word_goal = 1500
let g:auctoribus_char_goal = 15000
let g:auctoribus_speaking_goal = 30
let g:auctoribus_reading_goal = 40

set laststatus=2
set statusline=%{b:auctoribus_words}/%{g:auctoribus_word_goal}\ words\ \ %{b:auctoribus_bytes}/%{g:auctoribus_char_goal}\ chars\ \ %{b:auctoribus_speaking_time}/%{g:auctoribus_speaking_goal}\ mins\ speaking\ \ %{b:auctoribus_reading_time}/%{g:auctoribus_reading_goal}\ mins\ reading
