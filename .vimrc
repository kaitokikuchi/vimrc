" vim: foldlevel=0 sts=2 sw=2 smarttab et ai textwidth=0
if !&compatible
  " disable vi compatible features
  set nocompatible
endif

" Skip initialization for vim-tiny or vim-small
if !1 | finish | endif

" Variables {{{
if !exists($MYGVIMRC)
  let $MYGVIMRC = expand("~/.gvimrc")
endif

let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_darwin = has('mac') || has('macunix') || has('gui_macvim')
let s:is_linux = !s:is_windows && !s:is_cygwin && !s:is_darwin

let s:config_root = expand('~/.vim')
let s:bundle_root = s:config_root . '/bundle'

if s:is_windows
  " use english interface
  language message en
  " exchange path separator
  set shellslash
else
  " use english interface
  language message C
endif

" release autogroup in MyAutoCmd
augroup MyAutoCmd
  autocmd!
augroup END

" use ';' insted of '\'
" use <Leader> in global plugin
let g:mapleader = ';'
" use <LocalLeader> in filetype plugin
let g:maplocalleader = ','

" release keymappings for plugin
nnoremap ; <Nop>
xnoremap ; <Nop>
nnoremap , <Nop>
xnoremap , <Nop>

" reset runtimepath
if has('vim_starting')
  if s:is_windows
    " set runtimepath
    let &runtimepath = join([
      \ s:config_root,
      \ expand('$VIM/runtime'),
      \ s:config_root . '/after'], ',')
  else
    " reset runtimepath to default
    set runtimepath&
  endif

endif
"}}}

" Keymapping {{{

" extra ESC
inoremap jj <Esc>

" remove highlight with pressing ESC twice
nmap <silent> <Esc><Esc> :<C-u>nohlsearch<CR>

" find words selected with *
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>
" Make the word center when jumped
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" Increase scrolling speed
nnoremap <C-e> 2<C-e>
nnoremap <C-y> 2<C-y>

" Remap j and k to act as expected when used on long, wrapped, lines
nnoremap j gj
nnoremap k gk

" Select till a end of a line
vnoremap v $h

" Jump to matching pairs easily with Tab
nnoremap <Tab> %
vnoremap <Tab> %

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>

" toggle
set pastetoggle=<F2>
nnoremap [toggle] <Nop>
nmap T [toggle]
nnoremap <silent> [toggle]s :<C-u>setl spell!<CR>:setl spell?<CR>
nnoremap <silent> [toggle]l :<C-u>setl list!<CR>:setl list?<CR>
nnoremap <silent> [toggle]t :<C-u>setl expandtab!<CR>:setl expandtab?<CR>
nnoremap <silent> [toggle]w :<C-u>setl wrap!<CR>:setl wrap?<CR>

"}}}

" Plugins {{{
let s:noplugin = 0
let s:neobundle_root = s:bundle_root . "/neobundle.vim"
if !isdirectory(s:neobundle_root) || v:version < 702
  let s:noplugin = 1
else
  if has('vim_starting')
      execute "set runtimepath+=" . s:neobundle_root
  endif
  call neobundle#rc(s:bundle_root)

  " Let NeoBundle manage NeoBundle
  NeoBundleFetch 'Shougo/neobundle.vim'

  " Enable async process via vimproc
  NeoBundle "Shougo/vimproc", {
    \ "build": {
    \   "windows"   : "make -f make_mingw32.mak",
    \   "cygwin"    : "make -f make_cygwin.mak",
    \   "mac"       : "make -f make_mac.mak",
    \   "unix"      : "make -f make_unix.mak",
    \ }}

  " Recognize charcode automatically
  NeoBundle "banyan/recognize_charcode.vim"

  " Style / Display {{{
  NeoBundle "vim-scripts/desert256.vim"
  NeoBundle "jnurmine/Zenburn"
  NeoBundle "tomasr/molokai"
  NeoBundle "nanotech/jellybeans.vim"
  NeoBundle "vim-colors-solarized"
  NeoBundle "Lokaltog/vim-powerline"
  let s:hooks = neobundle#get_hooks("vim-powerline")
  function! s:hooks.on_source(bundle)
    let g:Powerline_symbols = 'fancy'
  endfunction

  NeoBundle "jceb/vim-hier"
  NeoBundle "vim-scripts/restore_view.vim"

  NeoBundle "nathanaelkane/vim-indent-guides"
  let s:hooks = neobundle#get_hooks("vim-indent-guides")
  function! s:hooks.on_source(bundle)
    let g:indent_guides_guide_size = 1
    nnoremap <silent> [toggle]i  :IndentGuidesToggle<CR>
    IndentGuidesEnable
  endfunction

  NeoBundleLazy "vim-scripts/ShowMarks", {
        \ "autoload": {
        \   "commands": ["ShowMarksPlaceMark", "ShowMarksToggle"],
        \ }}
  nnoremap [showmarks] <Nop>
  nmap M [showmarks]
  nnoremap [showmarks]m :ShowMarksPlaceMark<CR>
  nnoremap [showmarks]t :ShowMarksToggle<CR>
  let s:hooks = neobundle#get_hooks("ShowMarks")
  function! s:hooks.on_source(bundle)
    let showmarks_text = '»'
    let showmarks_textupper = '»'
    let showmarks_textother = '»'
    let showmarks_hlline_lower = 0
    let showmarks_hlline_upper = 1
    let showmarks_hlline_other = 0
    " ignore ShowMarks on buffer type of
    " Help, Non-modifiable, Preview Quickfix
    let showmarks_ignore_type = 'hmpq'
  endfunction

  NeoBundleLazy "skammer/vim-css-color", {
        \ "autoload": {
        \   "filetypes": ["html", "css", "less", "sass", "javascript", "coffee", "coffeescript", "djantohtml"],
        \ }}
  " }}}

  " Syntax / Indent / Omni {{{
  " syntax /indent /filetypes for git
  NeoBundleLazy 'tpope/vim-git', {'autoload': {
        \ 'filetypes': 'git' }}
  " syntax for CSS3
  NeoBundleLazy 'hail2u/vim-css3-syntax', {'autoload': {
        \ 'filetypes': 'css' }}
  " syntax for HTML5
  NeoBundleLazy 'othree/html5.vim', {'autoload': {
        \ 'filetypes': ['html', 'djangohtml'] }}
  " syntax /indent /omnicomplete for LESS
  NeoBundleLazy 'groenewege/vim-less.git', {'autoload': {
        \ 'filetypes': 'less' }}
  " syntax for SASS
  NeoBundleLazy 'cakebaker/scss-syntax.vim', {'autoload': {
        \ 'filetypes': 'sass' }}
  " QML
  NeoBundleLazy "peterhoeg/vim-qml", {'autoload': {
        \ 'filetypes': ['qml', 'qml/qmlscene'] }}
  " }}}

  " File Management {{{
  
  NeoBundle "thinca/vim-template"
  autocmd MyAutoCmd User plugin-template-loaded call s:template_keywords()
  function! s:template_keywords()
    silent! %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
    silent! %s/<+FILENAME+>/\=expand('%:r')/g
  endfunction
  autocmd MyAutoCmd User plugin-template-loaded
        \   if search('<+CURSOR+>')
        \ |   silent! execute 'normal! "_da>'
        \ | endif

  NeoBundleLazy "Shougo/unite.vim", {
        \ "autoload": {
        \   "commands": ["Unite", "UniteWithBufferDir"]
        \ }}
  NeoBundleLazy 'h1mesuke/unite-outline', {
        \ "autoload": {
        \   "unite_sources": ["outline"],
        \ }}
  nnoremap [unite] <Nop>
  nmap U [unite]
  nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
  nnoremap <silent> [unite]b :<C-u>Unite buffer<CR>
  nnoremap <silent> [unite]r :<C-u>Unite register<CR>
  nnoremap <silent> [unite]m :<C-u>Unite file_mru<CR>
  nnoremap <silent> [unite]c :<C-u>Unite bookmark<CR>
  nnoremap <silent> [unite]o :<C-u>Unite outline<CR>
  nnoremap <silent> [unite]t :<C-u>Unite tab<CR>
  nnoremap <silent> [unite]w :<C-u>Unite window<CR>
  let s:hooks = neobundle#get_hooks("unite.vim")
  function! s:hooks.on_source(bundle)
    " start unite in insert mode
    let g:unite_enable_start_insert = 1
    " use vimfiler to open directory
    call unite#custom_default_action("source/bookmark/directory", "vimfiler")
    call unite#custom_default_action("directory", "vimfiler")
    call unite#custom_default_action("directory_mru", "vimfiler")
    autocmd MyAutoCmd FileType unite call s:unite_settings()
    function! s:unite_settings()
      imap <buffer> <Esc><Esc> <Plug>(unite_exit)
      nmap <buffer> <Esc> <Plug>(unite_exit)
      nmap <buffer> <C-n> <Plug>(unite_select_next_line)
      nmap <buffer> <C-p> <Plug>(unite_select_previous_line)
    endfunction
  endfunction

  NeoBundleLazy "Shougo/vimfiler", {
        \ "depends": ["Shougo/unite.vim"],
        \ "autoload": {
        \   "commands": ["VimFilerTab", "VimFiler", "VimFilerExplorer"],
        \   "mappings": ['<Plug>(vimfiler_switch)'],
        \   "explorer": 1,
        \ }}
  nnoremap <Leader>e :VimFilerExplorer<CR>
  " close vimfiler automatically when there are only vimfiler open
  autocmd MyAutoCmd BufEnter * if (winnr('$') == 1 && &filetype ==# 'vimfiler') | q | endif
  let s:hooks = neobundle#get_hooks("vimfiler")
  function! s:hooks.on_source(bundle)
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_enable_auto_cd = 1

    " ignore swap, backup, temporary files
    let g:vimfiler_ignore_pattern = '\.pyc$'

    " vimfiler specific key mappings
    autocmd MyAutoCmd FileType vimfiler call s:vimfiler_settings()
    function! s:vimfiler_settings()
      " ^^ to go up
      nmap <buffer> ^^ <Plug>(vimfiler_switch_to_parent_directory)
      " use R to refresh
      nmap <buffer> R <Plug>(vimfiler_redraw_screen)
      " overwrite C-l ignore <Plug>(vimfiler_redraw_screen)
      nmap <buffer> <C-l> <C-w>l
      " overwrite C-j ignore <Plug>(vimfiler_switch_to_history_directory)
      nmap <buffer> <C-j> <C-w>j
    endfunction
  endfunction

  NeoBundleLazy "mattn/gist-vim", {
        \ "depends": ["mattn/webapi-vim"],
        \ "autoload": {
        \   "commands": ["Gist"],
        \ }}

  " vim-fugitive use `autocmd` a lost so cannot be loaded with Lazy
  NeoBundle "tpope/vim-fugitive"
  "NeoBundleLazy "tpope/vim-fugitive", {
  "      \ "autoload": {
  "      \   "commands": [
  "      \     "Gstatus", "Gwrite", "Gread", "Gmove",
  "      \     "Gremove", "Gcommit", "Gblame", "Gdiff",
  "      \     "Gbrowse",
  "      \ ]}}
  NeoBundleLazy "gregsexton/gitv", {
        \ "depends": ["tpope/vim-fugitive"],
        \ "autoload": {
        \   "commands": ["Gitv"],
        \ }}
  "}}}

  " Editing support {{{
  NeoBundle 'tpope/vim-surround'
  NeoBundle 'vim-scripts/Align'
  NeoBundle 'vim-scripts/YankRing.vim'
  let s:hooks = neobundle#get_hooks("YankRing.vim")
  function! s:hooks.on_source(bundle)
    let yankring_history_file = ".yankring_history"
  endfunction

  if has('lua') && (v:version > 703 || v:version == 703 && has('patch885'))
    NeoBundleLazy "Shougo/neocomplete.vim", {
          \ "autoload": {
          \   "insert": 1,
          \ }}
    let s:hooks = neobundle#get_hooks("neocomplete.vim")
    function! s:hooks.on_source(bundle)
      let g:acp_enableAtStartup = 0
      let g:neocomplete#enable_smart_case = 1
      let g:neocomplete#sources#syntax#min_keyword_length = 3
    endfunction
    function! s:hooks.on_post_source(bundle)
      NeoCompleteEnable
    endfunction
  else
    NeoBundleLazy "Shougo/neocomplcache.vim", {
          \ "autoload": {
          \   "insert": 1,
          \ }}
    let s:hooks = neobundle#get_hooks("neocomplcache.vim")
    function! s:hooks.on_source(bundle)
      let g:acp_enableAtStartup = 0
      let g:neocomplcache_enable_smart_case = 1
      let g:neocomplcache_min_syntax_length = 3
      NeoComplCacheEnable
    endfunction
  endif

  NeoBundleLazy "Shougo/neosnippet.vim", {
        \ "depends": ["honza/vim-snippets"],
        \ "autoload": {
        \   "insert": 1,
        \ }}
  let s:hooks = neobundle#get_hooks("neosnippet.vim")
  function! s:hooks.on_source(bundle)
    " Plugin key-mappings.
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    xmap <C-k>     <Plug>(neosnippet_expand_target)
    " SuperTab like snippets behavior.
    imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
    \ "\<Plug>(neosnippet_expand_or_jump)"
    \: pumvisible() ? "\<C-n>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
    \ "\<Plug>(neosnippet_expand_or_jump)"
    \: "\<TAB>"
    " For snippet_complete marker.
    if has('conceal')
      set conceallevel=2 concealcursor=i
    endif
    " Enable snipMate compatibility feature.
    let g:neosnippet#enable_snipmate_compatibility = 1
    " Tell Neosnippet about the other snippets
    let g:neosnippet#snippets_directory=s:bundle_root . '/vim-snippets/snippets'
  endfunction

  NeoBundleLazy "sjl/gundo.vim", {
        \ "autoload": {
        \   "commands": ['GundoToggle'],
        \}}
  nnoremap <Leader>g :GundoToggle<CR>

  NeoBundleLazy "vim-scripts/TaskList.vim", {
        \ "autoload": {
        \   "mappings": ['<Plug>TaskList'],
        \}}
  nmap <Leader>T <plug>TaskList
  "}}}

  " Programming {{{
  NeoBundleLazy "thinca/vim-quickrun", {
        \ "autoload": {
        \   "mappings": [['nxo', '<Plug>(quickrun)']]
        \ }}
  nmap <Leader>r <Plug>(quickrun)
  let s:hooks = neobundle#get_hooks("vim-quickrun")
  function! s:hooks.on_source(bundle)
    if has('clientserver')
      let g:quickrun_config = {
            \ "*": {"runner": "remote/vimproc"}
            \ }
    else
      let g:quickrun_config = {
            \ "*": {"runner": "remote/vimproc"}
            \ }
    endif
    " QML
    let g:quickrun_config['qml/qmlscene'] = {
            \ 'command' : 'qmlviewer',
            \ 'exec'    : '%c %s:p',
            \ 'quickfix/errorformat' : 'file:\/\/%f:%l %m',
            \ }
    let g:quickrun_config['qml'] = g:quickrun_config['qml/qmlscene']
  endfunction

  NeoBundleLazy 'majutsushi/tagbar', {
        \ "autload": {
        \   "commands": ["TagbarToggle"],
        \ },
        \ "build": {
        \   "mac": "brew install ctags",
        \ }}
  nmap <Leader>t :TagbarToggle<CR>

  NeoBundle "scrooloose/syntastic", {
        \ "build": {
        \   "mac": ["pip install pyflake", "npm -g install coffeelint"],
        \   "unix": ["pip install pyflake", "npm -g install coffeelint"],
        \ }}

  " jQuery
  NeoBundleLazy "jQuery", {'autoload': {
        \ 'filetypes': ['coffee', 'coffeescript', 'javascript', 'html', 'djangohtml'] }}
  " CoffeeScript
  NeoBundleLazy 'kchmck/vim-coffee-script', {'autoload': {
        \ 'filetypes': ['coffee', 'coffeescript'] }}

  NeoBundleLazy 'mattn/zencoding-vim', {'autoload': {
        \ 'filetypes': ['html', 'djangohtml'] }}

  " Python {{{
  NeoBundleLazy "lambdalisue/vim-django-support", {
        \ "autoload": {
        \   "filetypes": ["python", "python3", "djangohtml"]
        \ }}
  NeoBundleLazy "jmcantrell/vim-virtualenv", {
        \ "autoload": {
        \   "filetypes": ["python", "python3", "djangohtml"]
        \ }}
  NeoBundleLazy "davidhalter/jedi-vim", {
        \ "autoload": {
        \   "filetypes": ["python", "python3", "djangohtml"],
        \   "build": {
        \     "mac": "pip install jedi",
        \     "unix": "pip install jedi",
        \   }
        \ }}
  let s:hooks = neobundle#get_hooks("jedi-vim")
  function! s:hooks.on_source(bundle)
    let g:jedi#auto_vim_configuration = 0
    let g:jedi#popup_select_first = 0
    let g:jedi#show_function_definition = 1
    let g:jedi#rename_command = '<Leader>R'
    let g:jedi#goto_command = '<Leader>G'
  endfunction
  " }}}
  
  "}}}

  " Pandoc {{{
  NeoBundleLazy "vim-pandoc/vim-pandoc", {
        \ "autoload": {
        \   "filetypes": ["text", "pandoc", "markdown", "rst", "textile"],
        \ }}
  NeoBundleLazy "lambdalisue/shareboard.vim", {
        \ "autoload": {
        \   "commands": ["ShareboardPreview", "ShareboardCompile"],
        \ },
        \ "build": {
        \   "mac": "pip install shareboard",
        \   "unix": "pip install shareboard",
        \ }}
  function! s:shareboard_settings()
    nnoremap <buffer>[shareboard] <Nop>
    nmap <buffer><Leader> [shareboard]
    nnoremap <buffer><silent> [shareboard]v :ShareboardPreview<CR>
    nnoremap <buffer><silent> [shareboard]c :ShareboardCompile<CR>
  endfunction
  autocmd MyAutoCmd FileType rst,text,pandoc,markdown,textile call s:shareboard_settings()
  let s:hooks = neobundle#get_hooks("shareboard.vim")
  function! s:hooks.on_source(bundle)
    let g:shareboard_command = expand('~/.vim/shareboard/command.sh markdown+autolink_bare_uris+abbreviations')
    " add ~/.cabal/bin to PATH
    let $PATH=expand("~/.cabal/bin:") . $PATH
  endfunction
  " }}}

  " Ramdisk {{{
  function! s:ramdisk_settings()
    if s:is_windows
      let l:ramdisk_prefix = 'R:\'
    elseif s:is_darwin
      " http://sourceforge.jp/projects/rom/
      let l:ramdisk_prefix = '/Volumes/RamDisk/'
    elseif s:is_linux
      " mount -t tmpfs -o size=128m tmpfs /mnt/ramdisk
      let l:ramdisk_prefix = '/mnt/ramdisk'
    else
      let l:ramdisk_prefix = ''
    endif
    " use ramdisk only when the directory exists
    if l:ramdisk_prefix && isdirectory(l:ramdisk_prefix)
      let g:neocomplete_temporary_dir = l:ramdisk_prefix . '.neocon'
      let g:neocomplcache_temporary_dir = l:ramdisk_prefix . '.neocon'
      let g:vimfiler_data_directory = l:ramdisk_prefix . '.vimfiler'
      let g:unite_data_directory = l:ramdisk_prefix . '.unite'
      let g:ref_cache_dir = l:ramdisk_prefix . '.vim_ref_cache'
    endif
  endfunction
  call s:ramdisk_settings()
  " }}}
  
  " install missing plugins
  NeoBundleCheck

  unlet s:hooks
endif
filetype plugin indent on
"}}}

" Encoding {{{
if s:noplugin == 1
  set encoding=utf-8
  if !has('gui_running')
      set termencoding=               " use same encoding as `encoding`
      if s:is_windows
      set termencoding=cp932
      endif
  endif

  set fileformat=unix
  set fileformats=unix,dos,mac
  set ambiwidth=double            " a fullwidth character is displayed in vim
                                  " properly
  set fileencoding=utf8
  set fileencodings=utf-8,sjis,iso-2022-jp,euc-jp

  " Command group opening with a specific character code again."{{{
  " In particular effective when I am garbled in a terminal.
  " Open in UTF-8 again.
  command! -bang -bar -complete=file -nargs=? Utf8 edit<bang> ++enc=utf-8 <args>
  " Open in iso-2022-jp again.
  command! -bang -bar -complete=file -nargs=? Iso2022jp edit<bang> ++enc=iso-2022-jp <args>
  " Open in Shift_JIS again.
  command! -bang -bar -complete=file -nargs=? Cp932 edit<bang> ++enc=cp932 <args>
  " Open in EUC-jp again.
  command! -bang -bar -complete=file -nargs=? Euc edit<bang> ++enc=euc-jp <args>
  " Open in UTF-16 again.
  command! -bang -bar -complete=file -nargs=? Utf16 edit<bang> ++enc=ucs-2le <args>
  " Open in UTF-16BE again.
  command! -bang -bar -complete=file -nargs=? Utf16be edit<bang> ++enc=ucs-2 <args>
  " Aliases.
  command! -bang -bar -complete=file -nargs=? Jis  Iso2022jp<bang> <args>
  command! -bang -bar -complete=file -nargs=? Sjis  Cp932<bang> <args>
  command! -bang -bar -complete=file -nargs=? Unicode Utf16<bang> <args>
  "}}}

  " Appoint a line feed. {{{
  command! -bang -complete=file -nargs=? WUnix
        \ write<bang> ++fileformat=unix <args> | edit <args>
  command! -bang -complete=file -nargs=? WDos
        \ write<bang> ++fileformat=dos <args> | edit <args>
  command! -bang -complete=file -nargs=? WMac
        \ write<bang> ++fileformat=mac <args> | edit <args>
  "}}}

endif

if has('multi_byte_ime')
  set iminsert=0 imsearch=0
endif
" }}}

" Search {{{
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch      " highlight search terms

cnoremap <expr> /
      \ getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ?
      \ getcmdtype() == '?' ? '\?' : '?'

" }}}

" Edit {{{
set smarttab
set expandtab       " exchange tab to spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround      " use multiple of shiftwidth when indenting
                    " with '<' and '>'
set autoread        " automatically reload when the file is changed
set infercase       " ignore case on insert completion

set autoindent
set copyindent      " copy the previous indentation level

set virtualedit=all " allow the cursor going to invalid place

set modeline        " enable modeline
set showmatch       " highlight partner
set matchtime=3

" do not start with comment on pressing 'o'
set formatoptions-=o

" use clipboard register
if has('unnamedplus')
  set clipboard& clipboard+=unnamedplus
else
  set clipboard& clipboard+=unnamed
endif

" allow backspacing over everything in insert mode
set backspace=indent,eol,start
" highlight when cursor moved
set cpoptions-=m
" add <>
set matchpairs& matchpairs+=<:>

" use grep
set grepprg=grep\ -nH
" exclude = from isfilename
set isfname-==

" keymapping timeout
set timeout timeoutlen=3000 ttimeoutlen=100
" CursorHold time
set updatetime=1000

" set swap directory
set directory& directory-=.
if v:version >= 703
  set undofile
  let &undodir=&directory
endif

" set tag file. don't search tags in pwd and search upward
set tags& tags-=tags tags+=./tags;
if v:version < 703 || (v:version == 7.3 && !has('patch336'))
  set notagbsearch
endif

set keywordprg=:help

" hide buffer insted of closing to prevent Undo history
set hidden
" use opend buffer insted of create new buffer
set switchbuf=useopen

" do not create backup
set nowritebackup
set nobackup
set noswapfile
set backupdir=~/.vim/tmp

" set default lang for spell check
set spelllang=en_us
set nospell
" }}}

" Folding {{{
set foldenable
set foldcolumn=2
set foldlevel=1
set foldnestmax=5
set foldmethod=marker

" }}}

" Display {{{
syntax on
set list
set number
if s:is_windows
  set listchars=tab:>-,trail:-,extends:>,precedes:<
else
  set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲
endif
set wrap                            " wrap long text
set textwidth=0                     " do not automatically insert newline
set whichwrap+=h,l,<,>,[,],b,s,~
set laststatus=2                    " always display statusline
set scrolloff=4
set cmdheight=2                     " height of command line
set showcmd                         " show command on statusline

" turn down a long line appointed in 'breakat'
set linebreak
set showbreak=>\ \ \
set breakat=\ \ ;:,!?

" do not display greeting message
set shortmess=aTI

" store cursor, folds, slash, unix on view
set viewoptions=cursor,folds,slash,unix

" disable bells
set t_vb=
set novisualbell

" display candidate supplement
set nowildmenu
set wildmode=list:longest,full

set history=200
set showfulltag                     " display all the information of the tag
                                    " by the supplement of the Insert mode
set wildoptions=tagfile             " can supplement a tag in a command-line

" completion settings
set completeopt=menuone
set complete=.                      " don't complete from other buffer
set pumheight=20                    " height of popup menu

set report=0                        " report changes

" maintain a current line at the time of movement as much as possible
set nostartofline

" don't redraw while macro executing
set lazyredraw

" do not omit it in @.
set display=lastline

if v:version >= 703
  set conceallevel=2 concealcursor=iv
  set colorcolumn=80
endif

" }}}

" Macro {{{
" vimrc convinience
command! Reloadrc source $MYVIMRC |
            \ if has('gui_running') | source $MYGVIMRC | endif
command! Configvrc edit $MYVIMRC
command! Configgrc edit $MYGVIMRC
command! Loadasrc exec 'source ' . expand('%:p')

nnoremap <Leader><Leader>c :Configvrc<CR>
nnoremap <Leader><Leader>g :Configgrc<CR>
nnoremap <Leader><Leader>r :Reloadrc<CR>
nnoremap <Leader><Leader>l :Loadasrc<CR>

"" automatically reload vimrc/gvimrc
"autocmd MyAutoCmd BufWritePost $MYVIMRC source $MYVIMRC |
"            \ if has('gui_running') | source $MYGVIMRC | endif
"autocmd MyAutoCmd BufWritePost $MYGVIMRC
"            \ if has('gui_running') | source $MYGVIMRC | endif
"
" open quickfix after make,grep, etc.
autocmd MyAutoCmd QuickfixCmdPost make,grep,grepadd,vimgrep copen
" quit quickfix, help ... with q
autocmd MyAutoCmd FileType help,qf nnoremap <buffer> q <C-w>c

" save the file as root with 'sudo'
cmap w!! w !sudo tee > /dev/null %

" automatically create the directory if it does not exist
function! s:mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force ||
        \ input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction
autocmd MyAutoCmd BufWritePre * call s:mkdir(expand('<afile>:p:h'), v:cmdbang)

" automatically change the directory when starting the vim
autocmd MyAutoCmd VimEnter * call s:ChangeCurrentDir('', '')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        lcd %:p:h
    else
        execute 'lcd' . a:directory
    endif

    if a:bang == ''
        pwd
    endif
endfunction

" Load settings for each location. (http://vim-users.jp/2009/12/hack112/)
autocmd MyAutoCmd BufNewFile,BufReadPost * call s:vimrc_local(expand('<afile>:p:h'))
function! s:vimrc_local(loc)
  let files = findfile('.vimrc.local', escape(a:loc, ' ') . ';', -1)
  for i in reverse(filter(files, 'filereadable(v:val)'))
    source `=i`
  endfor
endfunction

"}}}

" Style {{{
  set t_Co=256
  set background=light
  colorscheme solarized

  highlight Pmenu ctermbg=2
  highlight PmenuSel ctermbg=3
  highlight ColorColumn ctermbg=0 guibg=darkgray
  highlight Error term=undercurl cterm=undercurl gui=undercurl ctermfg=1 ctermbg=0 guisp=Red
  highlight Warning term=undercurl cterm=undercurl gui=undercurl ctermfg=4 ctermbg=0 guisp=Blue
  highlight qf_error_ucurl term=undercurl cterm=undercurl gui=undercurl guisp=Red
  highlight qf_warning_ucurl term=undercurl cterm=undercurl gui=undercurl guisp=Blue
"}}}

""
"" Vim-LaTeX
""
NeoBundle 'git://vim-latex.git.sourceforge.net/gitroot/vim-latex/vim-latex'
filetype plugin on
filetype indent on
set shellslash
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
let g:Imap_UsePlaceHolders = 1
let g:Imap_DeleteEmptyPlaceHolders = 1
let g:Imap_StickyPlaceHolders = 0
let g:Tex_DefaultTargetFormat = 'pdf'
"let g:Tex_FormatDependency_pdf = 'pdf'
"let g:Tex_FormatDependency_pdf = 'dvi,pdf'
""let g:Tex_FormatDependency_pdf = 'dvi,ps,pdf'
let g:Tex_FormatDependency_ps = 'dvi,ps'
let g:Tex_CompileRule_pdf = '/usr/texbin/ptex2pdf -l -u -ot "-synctex=1 -interaction=nonstopmode -file-line-error-style" $*'
"let g:Tex_CompileRule_pdf = '/usr/texbin/pdflatex -synctex=1
"-interaction=nonstopmode -file-line-error-style $*'
""let g:Tex_CompileRule_pdf = '/usr/texbin/lualatex -synctex=1
-interaction=nonstopmode -file-line-error-style $*'
"let g:Tex_CompileRule_pdf = '/usr/texbin/luajitlatex -synctex=1
"-interaction=nonstopmode -file-line-error-style $*'
""let g:Tex_CompileRule_pdf = '/usr/texbin/xelatex -synctex=1
-interaction=nonstopmode -file-line-error-style $*'
"let g:Tex_CompileRule_pdf = '/usr/texbin/dvipdfmx $*.dvi'
""let g:Tex_CompileRule_pdf = '/usr/local/bin/ps2pdf $*.ps'
let g:Tex_CompileRule_ps = '/usr/texbin/dvips -Ppdf -o $*.ps $*.dvi'
let g:Tex_CompileRule_dvi = '/usr/texbin/uplatex -synctex=1 -interaction=nonstopmode -file-line-error-style $*'
let g:Tex_BibtexFlavor = '/usr/texbin/upbibtex'
"let g:Tex_BibtexFlavor = '/usr/texbin/bibtex'
""let g:Tex_BibtexFlavor = '/usr/texbin/bibtexu'
let g:Tex_MakeIndexFlavor = '/usr/texbin/mendex $*.idx'
"let g:Tex_MakeIndexFlavor = '/usr/texbin/makeindex $*.idx'
""let g:Tex_MakeIndexFlavor = '/usr/texbin/texindy $*.idx'
let g:Tex_UseEditorSettingInDVIViewer = 1
let g:Tex_ViewRule_pdf = '/usr/bin/open'
"let g:Tex_ViewRule_pdf = '/usr/bin/open -a Preview.app'
""let g:Tex_ViewRule_pdf = '/usr/bin/open -a Skim.app'
"let g:Tex_ViewRule_pdf = '/usr/bin/open -a TeXShop.app'
""let g:Tex_ViewRule_pdf = '/usr/bin/open -a TeXworks.app'
"let g:Tex_ViewRule_pdf = '/usr/bin/open -a Firefox.app'
""let g:Tex_ViewRule_pdf = '/usr/bin/open -a "Adobe Reader.app"'

" load local vimrc
let s:local_vimrc = expand('~/.vimrc.local')
if filereadable(s:local_vimrc)
  execute 'source ' . s:local_vimrc
endif                                                           
