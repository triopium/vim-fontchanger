"NOTES:"
"Font is changed through let &guifont='DejaVu Sans Mono\, 10'. This single quoted string where fontname and fontsize is separated by '\,' works best for most fonts.

"GLOBAL VARIABLES:"
""let g:FontChangerList="default"
let g:FontChangerList=$HOME . "/.vim/nicefonts.vim"
""let g:FontDefault='Source Code Pro Medium\, 14'
""let g:FontDefault='Liberation Mono\, 14'

"# FONT SIZE BOUNDARIES
let s:minfontsize = 6
let s:maxfontsize = 25

"OPEN GUI FONT MENU:"
function! fontchanger#FontGuiSelect()
	set guifont=*
endf
""call fontchanger#FontGuiSelect()

"CHANGE FONT SIZE BY AMOUNT:
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
function! fontchanger#FontFavValidator()
	let l:defaultFontList=fontchanger#FontListMono()
	let l:favListValid=[]
	if filereadable(g:FontChangerList)
		let l:favlist=systemlist("cat " . g:FontChangerList)
		let l:favListValid=array#ListsConjunction(l:defaultFontList,l:favlist)
		if len(l:favListValid) > 0
			echom "Number of fonts valid:" len(l:favListValid)
		elseif len(l:favListValid) = 0
				echoerr "No font specified in favorite list is avaiable."
				echoerr "Reverting to default font list"
				let l:fvaListValid=l:defaultFontList
		endif
	endif
	return l:favListValid
endfunction
""echo fontchanger#FontFavValidator()

""EXTRACT CURRENT FONT SIZE:
function! fontchanger#ExtractCurSize()
		"Extract current font size"
		let l:pattsize='.* \(\d*\)'
		let l:cursize = substitute(&guifont, l:pattsize, '\1', '')
		return l:cursize
endfunction
""echo fontchanger#ExtractCurSize()

""EXTRACT CURRENT FONT NAME:
function! fontchanger#ExtractCurFont()
		"Current font name"
		let l:pattfont='\(.*\)\(\\, \d*\)'
		let l:curfont = substitute(&guifont, l:pattfont, '\1', '')
		return l:curfont
endfunction
""echo fontchanger#ExtractCurFont()

""CYCLE FONTS IN LIST:
function! fontchanger#FontCycler(amount)
	if has("gui_gtk2") && has("gui_running")
		let l:cursize=fontchanger#ExtractCurSize()
		let l:curfont=fontchanger#ExtractCurFont()
		"Check current font index in font list"
		let l:fontList=fontchanger#FontFavValidator()
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

" SHOW MENU BUFFER WITH LIST OF FONTS PARSED FROM SYSTEM:"
function! fontchanger#FontListMenu(buf_name,fontlist)
	"Buffer window number"
		call buffer#GoToScratch(a:buf_name,10)

	if filereadable(g:FontChangerList)
		let l:favlist=systemlist("cat " . g:FontChangerList)
		let l:j=10000
		for l:i in l:favlist
			let l:j+=1
			let l:hname="DynFont" . l:j
			let l:hicommand='highlight ' . l:hname . ' guifg=#00C800'
			let l:mcommand='syn match ' . l:hname . ' ' . shellescape('^' . l:i . '$')
			exe l:hicommand
			exe l:mcommand
		endfor
	endif


		nnoremap <buffer> <CR> :silent call fontchanger#FontSelectedChange()<CR>
		nnoremap <silent><buffer> f :call fontchanger#FontFav()<CR>
		nnoremap <buffer> d :call fontchanger#FontSell()<CR>
		nnoremap <buffer> q :bw<CR>
		exe "lcd " . $HOME . "/.vim/fonts/"
		"delete content of buffer"
		set ma
		%d_
		silent 0put =a:fontlist
		set noma
endfunction
""call fontchanger#FontListMenu("_FotnMonoMenu_",fontchanger#FontFavValidator())

command! FontMenuAll call fontchanger#FontListMenu("_FontMonoMenu_",fontchanger#FontListMono())
command! FontMenuFav call fontchanger#FontListMenu("_FontFacMenu_",fontchanger#FontFavValidator())

function! fontchanger#FontSelectedChange()
		let l:selectedFont=getline('.')
		let l:pattsize='\(.* \)*\(\d*\)$'
		let l:cursize=substitute(&gfn,l:pattsize,'\2','')
		let l:curface=l:selectedFont . '\, ' . l:cursize
		let &gfn=l:curface
endfunction

""ADD SELECTED FONT TO FAVORITE LIST:
function! fontchanger#FontFav()
	let l:nicefonts=$HOME . "/.vim/fonts/nicefonts.vim"
	if 	filereadable(g:FontChangerList)
		let l:selectedFont=getline('.')
		let l:nfl=systemlist("cat " . g:FontChangerList)
		if matchstr(l:nfl,l:selectedFont) == l:selectedFont
			echom "Already favorited"
		else
			silent exe "!echo" l:selectedFont ">>" g:FontChangerList
		endif
	else
		silent exe "!touch " . g:FontChangerList
		silent exe "!echo" getline('.') ">>" g:FontChangerList
	endif
	let l:hname='DynFont' . line('.')
	let l:hicommand='highlight ' . l:hname . ' guifg=#00C800'
	let l:mcommand='syn match ' . l:hname . ' ' . shellescape('^' . getline('.') . '$')
	exe l:hicommand
	exe l:mcommand
endfunction

""DELETE SELECTED FONT FROM FAVORITE LIST:
function! fontchanger#FontSell()
	if filereadable(g:FontChangerList)
		let l:selectedFont=getline('.')
		let l:comd='sed -i "/' . l:selectedFont . "/d\" "
		let l:comd.=l:comd . g:FontChangerList
		""echo l:comd
		call systemlist(l:comd)
		""set ma
		""normal! dd
		""set noma
		let l:hname='DynFontB' . line('.')
		let l:hicommand='highlight ' . l:hname . ' guifg=#C00000'
		let l:mcommand='syn match ' . l:hname . ' ' . shellescape('^' . getline('.') . '$')
		exe l:hicommand
		exe l:mcommand
	endif
endfunction
""echo fontchanger#FontSell()
