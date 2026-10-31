vim.g.dbs = {
  { name = 'sqlite_class',
    url =  'sqlite:~/dev/sqlite/Ex_Files_SQL_EssT/Exercise Files/WSDA_Music.db'
  },
  { name = 'perch',
    url =  'sqlite:~/dev/perch/storage/development.sqlite3'
  },
  { name = 'pgexercises',
    url = 'postgres://egresh@localhost:5432/exercises'
  },
  {
    name = 'book',
    url = 'postgres://earl.gresh@localhost:5432/entertainment_agency_example'
  },
  {
    name = 'youtube',
    url = 'postgres://postgres@localhost:5432/onlinestore'
  }
}

return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
  end,
  keys = {
    { "<leader>dd", "<cmd>DBUIToggle<cr>", desc = "DBUI Toggle" }
  },
}
