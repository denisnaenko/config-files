" ====================
" CORE SETTINGS
" ====================
set mouse=a                     " Enable mouse
set encoding=utf-8
set number                      " Show line numbers
set cursorline                  " Highlight current line
set noswapfile                  " Disable swapfiles
set scrolloff=7                 " Keep context when scrolling

" Indentation (Python-friendly defaults)
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab                   " Use spaces, not tabs
set autoindent
set smartindent

set fileformat=unix             " Ensure Unix line endings
filetype indent on              " Load filetype-specific indent files

" Window splitting behavior
set splitbelow                  " Horizontal splits open below
set splitright                  " Vertical splits open to the right

" Quick escape from Insert mode
inoremap jk <esc>

" Turn off search highlight
nnoremap <Leader><space> :nohlsearch<CR>

" Set leader to comma
let mapleader = ","

" ====================
" CURSOR SETTINGS
" ====================

" Change cursor shape and color based on mode
set guicursor=

" Detailed guicursor settings for better visibility
set guicursor+=n-v-c:block-Cursor
set guicursor+=i:ver25-Cursor  " Insert mode: vertical bar, 25% width
set guicursor+=r:hor20-Cursor  " Replace mode: horizontal bar, 20% height
set guicursor+=c:block-Cursor

" Optional: Blinking cursor in Insert mode
" set guicursor+=i:blinkwait500-blinkon500-blinkoff500

" Force a specific, highly visible color for the cursor.
" This OVERRIDES the theme's cursor color.
highlight Cursor guifg=white guibg=red
highlight iCursor guifg=white guibg=steelblue " Color for insert mode

" ====================
" VIM-PLUG PLUGINS
" ====================
call plug#begin('~/.vim/plugged')

" LSP and Completion Core (ESSENTIAL)
Plug 'neovim/nvim-lspconfig'     " Configure LSP clients
Plug 'hrsh7th/nvim-cmp'          " Autocompletion plugin
Plug 'hrsh7th/cmp-nvim-lsp'      " LSP source for nvim-cmp
Plug 'L3MON4D3/LuaSnip'          " Snippet engine

" Language Support (ONLY WHAT YOU NEED)
" Plug 'simrat39/rust-tools.nvim'  // UNCOMMENT IF YOU START USING RUST

" Color Schemes (Try these instead of Gruvbox)
Plug 'sainnhe/gruvbox-material'  " A more modern, material version of Gruvbox
Plug 'navarasu/onedark.nvim'     " A very popular, dark theme
Plug 'olimorris/onedarkpro.nvim' " Another excellent OneDark variant
Plug 'rebelot/kanagawa.nvim'     " A beautiful, serene theme

" Fuzzy Finder (File navigation)
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.5' }
Plug 'nvim-lua/plenary.nvim'     " Dependency for Telescope

" Optional but Useful
Plug 'ray-x/lsp_signature.nvim'  " Show function signatures as you type

call plug#end()

" ====================
" APPEARANCE
" ====================
set termguicolors               " Enable true color support

" Try one of these themes. Uncomment the one you like.
" colorscheme onedark
" colorscheme gruvbox-material
colorscheme kanagawa

" ====================
" LSP & COMPLETION SETUP (Lua)
" ====================
lua << EOF

-- Set up nvim-cmp
local cmp = require'cmp'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'buffer' },
  })
})

-- Set up lspconfig for your languages
local lspconfig = require('lspconfig')

-- Use a common on_attach function to map keys
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true, buffer = bufnr }
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
end

-- Configure specific LSP servers
lspconfig.clangd.setup { -- C / C++
  on_attach = on_attach,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
  },
}
lspconfig.pyright.setup { -- Python
  on_attach = on_attach,
}

-- Optional: Rust setup. Uncomment if you need it.
-- lspconfig.rust_analyzer.setup {
--   on_attach = on_attach,
-- }

EOF

" ====================
" KEY MAPPINGS
" ====================

" Telescope (Fuzzy Find)
nnoremap <Leader>f <cmd>Telescope find_files<cr>
nnoremap <Leader>g <cmd>Telescope live_grep<cr>

" Buffer Navigation (Simplified)
nnoremap <Leader>n :bnext<CR>    " Next buffer
nnoremap <Leader>p :bprevious<CR> " Previous buffer
nnoremap <Leader>w :bdelete<CR>   " Kill current buffer

" Run code with Ctrl+h (Python, C, C++)
autocmd FileType python map <buffer> <C-h> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <C-h> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>

autocmd FileType c map <buffer> <C-h> :w<CR>:exec '!gcc -Wall -Wextra' shellescape(@%, 1) '-o out && ./out'<CR>
autocmd FileType c imap <buffer> <C-h> <esc>:w<CR>:exec '!gcc -Wall -Wextra' shellescape(@%, 1) '-o out && ./out'<CR>

autocmd FileType cpp map <buffer> <C-h> :w<CR>:exec '!g++ -Wall -Wextra -std=c++17' shellescape(@%, 1) '-o out && ./out'<CR>
autocmd FileType cpp imap <buffer> <C-h> <esc>:w<CR>:exec '!g++ -Wall -Wextra -std=c++17' shellescape(@%, 1) '-o out && ./out'<CR>

" Set a color column for Python
autocmd FileType python set colorcolumn=88
