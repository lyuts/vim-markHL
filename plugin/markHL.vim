"  Name        - markHL.vim
"  Description - Vim simple global plugin for easy line marking and jumping
"  Base plugin creator     - Nacho <pkbrister@gmail.com>
"  Fork author - lyuts <dioxinu@gmail.com>
"  
"  USAGE:
"
"  nnoremap <silent> <F2> :ToggleLocalMark<CR>
"  nnoremap <silent> <C-F2> :ToggleGlobalMark<CR>
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

call DetectOption("g:markHLGroupName", "Marks")

let s:gMarkStart = 'A'
let s:gMarkEnd = 'Z'
let s:lMarkStart = 'a'
let s:lMarkEnd = 'z'

hi LocalMarks term=reverse ctermfg=0 ctermbg=Yellow guibg=Grey40
hi GlobalMarks term=reverse ctermfg=0 ctermbg=Cyan guibg=Grey40

command! ToggleLocalMark :call ToggleHLMark()
command! ToggleGlobalMark :call ToggleHLMark(1)

function! s:GetFilePathForMark(mark)
    let bufferName = bufname(getpos("'".a:mark)[0])
    if bufferName[0] != "/"
        let bufferName = getcwd()."/".bufferName
    endif
    return bufferName
endfunction

function! s:MarkBelongsToCurrentFile(mark)
    let markPos = getpos("'".a:mark)[:1] " [bufnum, lnum]
    if s:IsGlobalMark(a:mark) != 0
        if s:GetFilePathForMark(a:mark) == expand("%:p") && markPos[1] > 0
            return 1
        endif
    elseif s:IsLocalMark(a:mark) != 0 && getpos("'".a:mark)[1] != 0
        return 1
    else
"        echohl Error | echomsg "[markHL::s:MarkBelongsToCurrentFile] Invalid or nonexisting mark: ".a:mark."!" | echohl None
        return 0
    endif
endfunction

function! s:HighlightMarks(group, from, to)
	let index = char2nr(a:from)
	while index <= char2nr(a:to)
        if s:MarkBelongsToCurrentFile(nr2char(index)) != 0
		    call matchadd(a:group, '\%'.line( "'".nr2char(index)).'l')
        endif
        let index = index + 1
	endwhile
endfunction

function! HLMarks()
	call clearmatches()
    call s:HighlightMarks("Local".g:markHLGroupName, s:lMarkStart, s:lMarkEnd)
    call s:HighlightMarks("Global".g:markHLGroupName, s:gMarkStart, s:gMarkEnd)
endfunction

function! ToggleHLMark(...)
    " Available marks are 65..90 - Global
    " Available marks are 97..122 - Local
    if a:0 > 0
        let markRangeStart = s:gMarkStart
        let markRangeEnd = s:gMarkEnd
    else
        let markRangeStart = s:lMarkStart
        let markRangeEnd = s:lMarkEnd
    endif

    let index = char2nr(markRangeStart)
    let markIndexToRemove = 0
    let markIndexToSet = 0
	while index <= char2nr(markRangeEnd) && (markIndexToRemove == 0)
        let mark = nr2char(index)
        if count(getpos("'".mark), 0) != 4 " mark is set, i.e. not [0,0,0,0]
            if s:MarkBelongsToCurrentFile(mark)
                if line('.') == line("'".mark)
                    let markIndexToRemove = index
                endif
            else
                if s:IsGlobalMark(mark) == 0 && markIndexToSet == 0
                    let markIndexToSet = index
                endif
            endif
        elseif markIndexToSet == 0
            let markIndexToSet = index
        endif
		let index = index + 1
	endwhile

    if markIndexToRemove
        call DelHLMark(nr2char(markIndexToRemove))
    else
        call AddHLMark(nr2char(markIndexToSet))
    endif
endfunction

function! AddHLMark(mark)
	if s:IsLocalMark(a:mark) || s:IsGlobalMark(a:mark)
		exe 'normal m'.a:mark
		call HLMarks()
    else
        echohl Error | echomsg "[markHL] Invalid mark: ".a:mark."!" | echohl None
	endif
endfunction

function! DelHLMark(mark)
	if s:IsLocalMark(a:mark) || s:IsGlobalMark(a:mark)
        exe 'delmarks '.a:mark
        call HLMarks()
    else
        echohl Error | echomsg "[markHL] Invalid mark: ".a:mark."!" | echohl None
	endif
endfunction

function! s:IsGlobalMark(mark)
    return a:mark >= s:gMarkStart && a:mark <= s:gMarkEnd
endfunction

function! s:IsLocalMark(mark)
    return a:mark >= s:lMarkStart && a:mark <= s:lMarkEnd
endfunction

