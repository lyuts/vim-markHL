"  Name        - markHL.vim
"  Description - Vim simple global plugin for easy line marking and jumping
"  Base plugin creator     - Nacho <pkbrister@gmail.com>
"  Fork author - lyuts <dioxinu@gmail.com>
"  
"  USAGE:
"
"  nnoremap <silent> <F2> :call ToggleHLMark("Marks")<CR>
"  nnoremap <silent> <S-F2> :MarksBrowser<CR>
"  nnoremap <silent> <S-A-F2> :call clearmatches()<CR>
"
"  Then, just jump from one mark to the next using the classic [' and ]' jumps
"  
"  Try it! it's nice!
"  
"  NOTE:
"  Of course, the highlight group I define ("Marks") should be tweaked to one's taste, 
"  and the same applies to the keyboard mappings.
"  
"  NOTE-UPDATE:
"  The classic marking method (ie. typing 'ma', 'mb', 'mc'...) can be used in
"  combination with this one, but one has to be careful not to overwrite an
"  existing mark. Check with the :marks command. HINT: the code marks from the
"  'a' to the 'z', so if there are not too many marks, one can safely assume
"  that the last ones ('z 'x 'y 'w ...) are safe to use.
"
"  Enjoy...

hi Marks term=reverse ctermfg=0 ctermbg=Yellow guibg=Grey40

function! HLMarks(group)
	call clearmatches()
	let index = char2nr('a')
	while index < char2nr('z')
		call matchadd( a:group, '\%'.line( "'".nr2char(index)).'l')
		let index = index + 1
	endwhile
endfunction

function! ToggleHLMark(group)
    " Available marks are 97..122
	let index = char2nr('a')
    let markExists = 0
    let freeMarkIndex = 0
	while index <= char2nr('z')
        let curMarkPos = line("'".nr2char(index))
        if line(".") == curMarkPos
            let markExists = 1
            break
        elseif curMarkPos == 0 && freeMarkIndex == 0
            let freeMarkIndex = index
        endif
		let index = index + 1
	endwhile

    if markExists == 1
        call DelHLMark(a:group, nr2char(index))
    else
        call AddHLMark(a:group, nr2char(freeMarkIndex))
    endif
endfunction

function! AddHLMark(group, markIndex)
	if a:markIndex <= 'z'
		exe 'normal m'.a:markIndex
		call HLMarks(a:group)
	endif
endfunction

function! DelHLMark(group, markIndex)
    exe 'delmarks '.a:markIndex
    call HLMarks(a:group)
endfunction

nmap <silent> <F5> :call ToggleHLMark("Marks")<CR>
nmap <silent> <S-F5> :call HLMarks("Marks")<CR>
nmap <silent> <S-A-F5> :call clearmatches()<CR>
