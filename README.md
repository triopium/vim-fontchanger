# vim-fontchanger
* quickly change font from system avaiable monospace fonts or from favorite list
* quickly change font size

# Motivation
* find gui font which works best for you and is plesant to the eye.
* Requirement for mono font:
** sufficiently distinguished charaters 0Ooij1lL
** easily readable
** space efficient
** aesthetics

# Dependency
linux
triorg/vim-array
triorg/vim-buffer

# Automatic mappings inside textual font menu (scratch buffer)
* f		'add to favorite list (green font)'
* d 	'delete from favorite list (red font)'
* q		'close window and wipe out scratch buffer
* enter	'change to font under cursor

# Example user mapings
* decrese font size:
nnoremap + :call fontchanger#SizeChanger(1) 
* increase font size:
nnoremap + :call fontchanger#SizeChanger(-1)
* display system avaiable mono fonts:
nnoremap :FontMenuAll<CR>
* display system avaiable favorite fonts
nnoremap :FontMenuFav<CR>

# Nice fonts
* favorite fonts should be put in ~/.vim/nicefonts.txt. File is created automaticaly when faved font with 'f' key.
* nice monospace examples
** Bitstream Vera Sans Mono
** CamingoCode
** BPmono
** Code New Roman
** DejaVu Sans Mono
** Cousine
** Hack
** Inconsolata
** Liberation Mono
** Monofonto
** Noto Mono
** PT Mono
** Source Code Pro
** Source Code Pro Medium
** Ubuntu Mono
Anonymous Pro
