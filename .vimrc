" Initially based on the Vim distribution's example vimrc, with
" additional inspiration from all over the web.

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" General options {{{
" Miscellaneous and Display {{{

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup                  " do not keep a backup file, use versions instead
else
  set backup                    " keep a backup file
  set backupdir=~/.backup/vim   " leave all the droppings in one place
endif

set history=500     " keep more command line history
set ruler           " show the cursor position all the time
set showcmd         " display commands as they're being entered
set incsearch       " do incremental searching
set ignorecase      " Do case insensitive matching
set smartcase       " But if search contains capitals, be sensitive
set scrolloff=3     " Keep some context visible when scrolling
set wildmenu        " Modern completion menu
set number          " line numbers

" wildmenu does shell-style completion AND tab-through
set wildmode=list:longest,full

" automatically flush to disk when using :make, changing buffers, etc.
" Alternatively, set hidden to allow moving around and leaving dirty files be
"set autowrite
set hidden

" use existing window if I try to open an already-open buffer
set switchbuf=useopen

" threshold for reporting number of lines changed
set report=0

" For modern standards in :TOhtml output
let html_use_css=1
let use_html=1

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  set cursorline
  colorscheme twilight  " last used: oceanblack
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  augroup END

else

  set autoindent        " always set autoindenting on

endif " has("autocmd")

if has("viminfo")

  " Allow some global variables to persist between sessions
  " Plugins sometimes use this to retain useful things
  " % saves and restores buffer list when started with no args
  set viminfo^=!,%

endif

"}}}

" Indentation {{{

" no-longer skinny tabs!
set tabstop=4

" set to the same as tabstop (see #4 in :help tabstop)
set shiftwidth=4

" if it looks like a tab, we can delete it like a tab
set softtabstop=4

" no tabs! spaces only..
set expandtab

" do not break lines when line length increases
set textwidth=0

" < and > will hit indentation levels instead of always -4/+4
set shiftround

" braces affect autoindentation
set smartindent

" Show matching brackets.
set showmatch
set matchtime=2

" figure out indent when ; is pressed
set cinkeys+=;

" align break with case in a switch
"set cinoptions+=b1

" Use attractive characters to show tabs & trailing spaces
set listchars=tab:»·,trail:·,eol:¬,nbsp:␣

"}}}

" Folding {{{

" fold only when I ask for it damnit!
""set foldmethod=marker

" close a fold when I leave it
""set foldclose=all
"}}}

" Colors {{{

highlight LineNr  term=underline    ctermfg=grey    guifg=grey
highlight CursorLine    guibg=Grey10
" No hideous pink default autocomplete menu
highlight PMenu gui=bold guibg=#CECECE guifg=#444444
"}}}

" Autocommands {{{
if has("autocmd")

  " When editing a file, always jump to the last known cursor position. {{{
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim), or for commit messages.
  autocmd BufReadPost * call SetCursorPosition()
  function! SetCursorPosition()
    if &filetype !~ 'commit\c'
      if line("'\"") > 0 && line("'\"") <= line("$")
        exe "normal g`\""
        normal! zz
      endif
    end
  endfunction
  "}}}
  
  " Skeletons {{{
  autocmd BufNewFile *.py silent 0read ~/.vim/skeleton/skeleton.py   | normal G
  "autocmd BufNewFile *.pl silent 0read ~/.vim/skeleton/perl.pl     | normal G
  "autocmd BufNewFile *.t  silent 0read ~/.vim/skeleton/perl-test.t | normal G
  "autocmd BufNewFile *.c  silent 0read ~/.vim/skeleton/c.c         | normal 4j$
  "autocmd BufNewFile *.hs silent 0read ~/.vim/skeleton/haskell.hs  | normal Gk$
  "}}}

  " Auto +x {{{
  au BufWritePost *.sh !chmod +x %
  au BufWritePost *.pl !chmod +x %
  "}}}

  " Automatically distribute my vimrc to the servers I use {{{
  "autocmd BufWritePost ~/.vimrc !scp ~/.vimrc valleyofwind.dyndns.org:.
  "autocmd BufWritePost ~/.vimrc !scp ~/.vimrc eidolos@crawl.akrasiac.org:.eidovimrc
  "autocmd BufWritePost ~/.vim/skeletons/* !scp % valleyofwind.dyndns.org:.vim/skeletons/
  "autocmd BufWritePost ~/.vim/skeletons/* !scp % eidolos@crawl.akrasiac.org:.vim/skeletons/
  "}}}

endif " has("autocmd")
"}}}

" Remappings {{{

" I'm drinkin' the comma-as-leader kool aid
let mapleader = ","

" Code completion shortcut
imap <f3> <C-x><C-o><C-p>

" Easy paste mode toggling
set pastetoggle=<F6>

" Toggle search hilighting
map <silent> <F11> :set invhlsearch<CR>
imap <silent> <F11> <C-o>:set invhlsearch<CR>
vmap <silent> <F11> :<C-u>set invhlsearch<CR>gv

" It's a fast-moving world these days -- does your scrolling keep up?
noremap <C-y> 2<C-y>
noremap <C-e> 2<C-e>

" Easy window split navigation {{{
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <C-h> <C-w>h
"}}}

" Lotsa TextMate-inspired Mappings
source ~/.vim/include/textmate-mappings.vim

"}}}

" Language- and plugin-specific Preferences {{{
if has("autocmd")

  " FileType Stuff {{{

  " Use leader+space to write and execute
  autocmd FileType vim map <buffer> <leader><space> :w!<cr>:source %<cr>
  autocmd FileType ruby map <buffer> <leader><space> :w!<cr>:!ruby %<cr>
  autocmd FileType python map <buffer> <leader><space> :w!<cr>:!python %<cr>

  " autocmd FileType python setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class,with
  autocmd FileType javascript,ruby,vim setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2

  let javascript_enable_domhtmlcss=1
  let xml_use_xhtml = 1                     " default xml to self-closing tags

  autocmd FileType html,xhtml,xml,htmldjango,htmljinja,eruby,mako setlocal expandtab shiftwidth=2 tabstop=2 softtabstop=2
  autocmd BufNewFile,BufRead *.mako setlocal ft=mako

  autocmd FileType mkd set ai formatoptions=tcroqn2 comments=n:>

  "}}}

  " NERDTree
  let NERDTreeWinPos          = 'right'
  let NERDTreeShowBookmarks   = 1

  " TaskList on bottom
  let g:tlWindowPosition      = 1

  " snipMate Setup and Support functions - scrooloose/snipmate-snippets
  source ~/.vim/snippets/support_functions.vim
  autocmd vimenter * call s:SetupSnippets()
  function! s:SetupSnippets()

    "if we're in a rails env then read in the rails snippets
    if filereadable("./config/environment.rb")
      call ExtractSnips("~/.vim/snippets/ruby-rails", "ruby")
      call ExtractSnips("~/.vim/snippets/eruby-rails", "eruby")
    endif

    call ExtractSnips("~/.vim/snippets/html", "eruby")
    call ExtractSnips("~/.vim/snippets/html", "xhtml")
    call ExtractSnips("~/.vim/snippets/html", "php")
  endfunction

endif " has("autocmd")

" Plugin Mappings {{{

" Ack Search
map <Leader>a :Ack<space>

" NERD tree - double-leader
map <Leader>, :NERDTreeToggle<cr>

"}}}
"}}}
"}}}

" vim:foldmethod=marker commentstring="%s

