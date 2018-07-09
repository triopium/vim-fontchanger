"NOTES:"
"Font is changed through let &guifont='DejaVu Sans Mono\, 10'. This single quoted string where fontname and fontsize is separated by '\,' works best for most fonts.

"GLOBAL VARIABLES:"
""let g:FontChangerList="default"
let g:FontChangerList=$HOME . "/.vim/fonts/nicefonts.vim"
""let g:FontDefault='Source Code Pro Medium\, 14'
""let g:FontDefault='Liberation Mono\, 14'

"# FONT SIZE BOUNDARIES
let s:minfontsize = 6
let s:maxfontsize = 25

"CHANGE FONT SIZE BY AMOUNT"
function! fontchanger#SizeChanger(amount)
	if has("gui_gtk2") && has("gui_running")
		"pattern to get current font size or font name"
		let l:pattsize='\(.* \)*\(\d*\)$'
		let l:cursize = substitute(&guifont, l:pattsize, '\2', '')
		let l:curfont = substitute(&guifont, l:pattsize, '\1', '')
    	let l:newsize = l:cursize + a:amount
		if (l:newsize <= s:maxfontsize) && (l:newsize >= s:minfontsize)
    		let l:newfont = l:curfont . l:newsize
			let &guifont=l:newfont
		endif
	else
    	echoerr "You need to run the GTK2 version of Vim to use this function."
	endif
endfunction
""call fontchanger#SizeChanger(1)
""call fontchanger#SizeChanger(-1)

"OPEN GUI FONT MENU:"
function! fontchanger#FontGuiSelect()
	set guifont=*
endf
""call fontchanger#FontGuiSelect()

"OBTAIN ALL MONOSPACE FONTS WITH DECLARED SPACING:
function! fontchanger#FontListMono()
	"# GET ALL MONOSPACE FONT THROUGH fc-list"
	let l:fontsList=systemlist("fc-list : family spacing | grep spacing | awk -F'[:]' '{print $1;}' | sort | uniq | tr -d '\\\\'")
	"# Reformat font list"
	let l:reformedFontsList=[]
	for l:i in l:fontsList
	"Extract name separated by comma"
	"exmp.: Source Code Pro,Source Code Pro Black → Source Code Pro Black
		let l:ifn=substitute(i,'.*,\(.*\)','\1','')
		call add(reformedFontsList,l:ifn)
	endfor
	return l:reformedFontsList
endfunction
""echo fontchanger#FontListMono()

"CHECK IF FONT SPECIFIED IN FAVORITE LIST ARE AVAILABLE AND RETURN LIST OF AVAIABLE FAVORITE FONTS:"
function! fontchanger#FontFavValidList()
	let l:defaultFontList=fontchanger#FontListMono()
	let l:favListValid=[]
	if g:FontChangerList ==# "default"
		let l:favListValid=l:defaultFontList
	else
		if filereadable(g:FontChangerList)
			let l:favlist=systemlist("cat " . g:FontChangerList)
			let l:favListValid=array#ListsConjunction(l:defaultFontList,l:favlist)
			if len(l:favListValid) > 0
				echom "Number of fonts valid:" len(l:favListValid)
			else
				echoerr "No fonts specified in favorite list avaiable."
				echoerr "Reverting to default font list"
				let l:fvaListValid=l:defaultFontList
			endif
		endif
	endif
	return l:favListValid
endfunction
""echo fontchanger#FontFavValidList()

"# CYCLE FONTS IN LIST"
"Pttern to extract current font name
""let s:pattsize='.* \(\d*\)'
""let s:pattfont='\(.*\)\(\\, \d*\)'
"""Test patterns:
"let test_fontname='Anonymous Pro Mono\, 10'
""echo substitute(test_fontname,s:pattsize,'\1','') . 'Hello'
""echo substitute(test_fontname,s:pattfont,'\1','') . 'Hello'

function! fontchanger#ExtractCurSize()
		"Extract current font size"
		let l:pattsize='.* \(\d*\)'
		let l:cursize = substitute(&guifont, l:pattsize, '\1', '')
		return l:cursize
endfunction
""echo fontchanger#ExtractCurSize()

function! fontchanger#ExtractCurFont()
		"Current font name"
		let l:pattfont='\(.*\)\(\\, \d*\)'
		let l:curfont = substitute(&guifont, l:pattfont, '\1', '')
		return l:curfont
endfunction
""echo fontchanger#ExtractCurFont() . " Hello"

function! fontchanger#FontCycler(amount)
	if has("gui_gtk2") && has("gui_running")
		let l:cursize=fontchanger#ExtractCurSize()
		let l:curfont=fontchanger#ExtractCurFont()
		"Check current font index in font list"
		let l:fontList=fontchanger#FontFavValidList()
		let l:idx=index(l:fontList,l:curfont)
		if (l:idx == -1)
			"Start cycling at 0 index"
			let l:newfont=l:fontList[0] . '\, ' . l:cursize
			let &guifont=l:newfont
		else
			"Number of items in font list"
			let l:nidx=len(l:fontList)
			"Modulo returns negative number for negative input. When
			"negative index is supplied to list, it will subset the list
			"from end.
			let l:newidx=(l:idx+a:amount)%l:nidx
			let l:newfont=l:fontList[l:newidx]
			"Check if font is avaiable on system"
			if matchstr(l:fontList,l:newfont) == l:newfont
				let &guifont=l:newfont . '\, ' . l:cursize
			else
				echoerr l:newfont "Font not avaible on system"
			endif
		endif
	else
    	echoerr "You need to run the GTK2 version of Vim to use this function."
	endif
endfunction
""call fontchanger#FontCycler(1)
""call fontchanger#FontCycler(-1)

"# SHOW MENU BUFFER WITH LIST OF FONTS PARSED FROM SYSTEM"
function! fontchanger#FontListMenu(buf_name,fontlist)
	"Buffer window number"
	let l:bfnr=bufwinnr(a:buf_name)
	if  l:bfnr > 0
	"If buffer is visible, go to it"
		exe l:bfnr . "wincmd w"
	elseif l:bfnr == winnr()
		echo "already selected"
	else
		"Create new buffer"
		""exe 'new' a:buf_name
		exe 'sp ' . a:buf_name
		"Buffer settings"
		"? not sure if to use nowrite or nofile (difference?)"
		:setlocal buftype=nofile
		:setlocal bufhidden=hide
		:setlocal noswapfile
		nnoremap <buffer> <CR> :silent call FontSelectedChange()<CR>
		nnoremap <buffer> f :silent call FontNiceListAdd()<CR>
		nnoremap <buffer> q :bw<CR>
		exe "lcd " . $HOME . "/.vim/fonts/"
	endif
		"delete content of buffer"
		set ma
		%d_
		silent 0put =a:fontlist
		set noma
endfunction
""call fontchanger#FontListMenu("_FotnMonoMenu_",fontchanger#FontFavValidList())

function! FontSelectedChange()
		let l:selectedFont=getline('.')
		let l:pattsize='\(.* \)*\(\d*\)$'
		let l:cursize=substitute(&gfn,l:pattsize,'\2','')
		let l:curface=l:selectedFont . '\, ' . l:cursize
		let &gfn=l:curface
endfunction

function! FontNiceListAdd()
	let l:nicefonts=$HOME . "/.vim/fonts/nicefonts.vim"
	if 	filereadable(l:nicefonts)
		let l:selectedFont=getline('.')
		let l:nfl=systemlist("cat " . l:nicefonts)
		if matchstr(l:nfl,l:selectedFont) == l:selectedFont
			echom "Already favorited"
		else
			exe "!echo" l:selectedFont ">>" l:nicefonts
		endif
	else
		!mkdir -p ~/.vim/fonts/
		exe "!touch " . l:nicefonts
	endif
endfunction
