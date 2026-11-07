" ==============================================================================
" 1. CORE SETTINGS & PERFORMANCE
" ==============================================================================
if empty($SSN_ROOT)
  let $SSN_ROOT = expand('<sfile>:p:h')
endif

set runtimepath^=$SSN_ROOT/.vim
set runtimepath+=$SSN_ROOT/.vim/after
let &packpath = &runtimepath

set nocompatible              " Be Vim, not Vi
set encoding=utf-8
set clipboard=exclude:.* " Fix slow startup on SSH/X11 connections

set directory=~/.vim/swap//,.      " Swap files
set backupdir=~/.vim/backup//,.    " Backup files
set undodir=~/.vim/undo//,.        " Undo history

" Create these directories automatically if they don't exist
if !isdirectory(expand('~/.vim/swap'))
  call mkdir(expand('~/.vim/swap'), 'p')
endif
if !isdirectory(expand('~/.vim/backup'))
  call mkdir(expand('~/.vim/backup'), 'p')
endif
if !isdirectory(expand('~/.vim/undo'))
  call mkdir(expand('~/.vim/undo'), 'p')
endif
" History & State
" Don't save limits on removable media, keep 100 lines of registers
set viminfo='10,\"100,:20,%,n~/.viminfo
set history=1000              " Keep more history (100 is too low for 2024)
set undolevels=1000           " Allow more undo steps

" ==============================================================================
" 2. UI & VISUALS
" ==============================================================================
syntax on                     " Syntax highlighting
set t_Co=256                  " 256 Color Support
colorscheme desert            " Your chosen color scheme

set nonu                      " no line numbers 
set ruler                     " Show cursor position
set laststatus=2              " Always show status line
set showcmd                   " Show partial commands
set showmode                  " Show current mode
set shortmess+=r              " abbreviated messages
set vb t_vb=                  " No visual bell / no beep

" Highlight the 81st column (Google Style Guide Limit)
" SANTHOSH: Override since on Python we geanearlly go for 100 columns!
highlight OverLength ctermbg=black ctermfg=white guibg=#FFD9D9
match OverLength /\%101v.*/

set nowrapscan

" ==============================================================================
" 3. INDENTATION & FORMATTING (Google Style)
" ==============================================================================
filetype plugin indent on     " Enable filetype-specific plugins

" Default Indentation (2 spaces, no tabs - Google Standard)
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab
set autoindent
" set smartindent
" set cindent

" File-specific overrides
if has("autocmd")
  " Makefiles require real tabs
  autocmd FileType make setlocal noexpandtab shiftwidth=4
  
  " Python indentation
  autocmd FileType python setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab
  
  " Text files - nice wrapping at 80 chars
  autocmd FileType text,markdown setlocal textwidth=80 wrap
endif

set backspace=indent,eol,start  " Make Backspace work as expected

if has("cscope")
    if executable("cscope")
        set csprg=cscope
    elseif executable("/usr/bin/cscope")
        set csprg=/usr/bin/cscope
    elseif executable("/usr/local/bin/cscope")
        set csprg=/usr/local/bin/cscope
    endif

    if executable(&csprg)
        set csto=0
        set cst
        " add any database in current directory
        if filereadable("cscope.out")
            cs add cscope.out
        endif
    endif
endif

" ==============================================================================
" 4. SEARCH & NAVIGATION
" ==============================================================================
set incsearch                 " Jump to match as you type
set hlsearch                  " Highlight search results
set ignorecase                " Case insensitive search...
set smartcase                 " ...unless you type a Capital letter
set magic                     " Enable extended regex
set wildmenu                  " Better command line completion
set wildmode=list:longest,full

" Turn off highlighting with <leader><cr>
nnoremap <silent> <leader><cr> :noh<CR>

" ==============================================================================
" 5. KEY MAPPINGS
" ==============================================================================
" Map Leader Key (Default is \)
let mapleader = "\\"

" Windows-style Undo/Redo (As requested)
nnoremap <C-Z> u
nnoremap <C-Y> <C-R>
inoremap <C-Z> <C-O>u
inoremap <C-Y> <C-O><C-R>

" Navigation Wraps
set whichwrap=h,l,~,[,]

" Window Management (F-keys)
nnoremap <silent><F2> :NERDTreeToggle<CR>
nnoremap <silent><F3> <C-w><C-w>
nnoremap <silent><F12> :q<CR>

" Fix Home/End keys for some terminals
map <Esc>[1~ <Home>
map <Esc>[4~ <End>
imap <Esc>[1~ <Home>
imap <Esc>[4~ <End>

" ==============================================================================
" 6. PLUGINS (vim-plug)
" ==============================================================================
call plug#begin($SSN_ROOT . '/.vim/plugged')

" Essentials
Plug 'tpope/vim-sensible'           " Defaults everyone agrees on
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'             " Fuzzy Finder (Critical for Pro workflow)
" Plug 'scrooloose/syntastic'         " Syntax checking
Plug 'dense-analysis/ale'

" Visuals
Plug 'altercation/vim-colors-solarized'
Plug 'inkarkat/vim-mark'            " Highlighting multiple words
Plug 'inkarkat/vim-ingo-library'    " Dependency for vim-mark

" Languages
Plug 'bfrg/vim-cpp-modern'          " Better C++ highlighting

" Markdown Preview Plugin
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

call plug#end()

" ALE Configuration
let g:ale_linters = {'python': ['flake8', 'pylint']}
let g:ale_fixers = {'python': ['black']}
let g:ale_lint_on_enter = 1
let g:ale_lint_on_text_changed = 'never' " Only lint on save to save battery/CPU
let g:ale_sign_column_always = 1         " Keeps the UI stable

" ==============================================================================
" 7. PLUGIN MAPPINGS
" ==============================================================================
" FZF Mappings (Ctrl-F for Files, Ctrl-R for History)
nnoremap <silent> <C-F> :Files<CR>
nnoremap <silent> <C-R> :History<CR>
