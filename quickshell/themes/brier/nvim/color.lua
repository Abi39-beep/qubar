local set = vim.api.nvim_set_hl

vim.cmd("hi clear")

-- base
set(0, "Normal", { fg = "#EEDDBB", bg = "#1A171C" })
set(0, "CursorLine", { bg = "#322932" })
set(0, "LineNr", { fg = "#CBB28F" })
set(0, "CursorLineNr", { fg = "#EEDDBB" })

-- syntax
set(0, "Comment", { fg = "#E3CEAD", italic = true })
set(0, "String", { fg = "#5B7035" })
set(0, "Function", { fg = "#157F78" })
set(0, "Keyword", { fg = "#DD3014" })
set(0, "Type", { fg = "#D3A03B" })

-- diagnostics
set(0, "DiagnosticError", { fg = "#DD3014" })
set(0, "DiagnosticWarn", { fg = "#D3A03B" })
set(0, "DiagnosticInfo", { fg = "#4A8494" })
set(0, "DiagnosticHint", { fg = "#157F78" })

-- neo-tree (Replaced NvimTree)
set(0, "NeoTreeNormal", { bg = "#1A171C" })
set(0, "NeoTreeNormalNC", { bg = "#1A171C" })
set(0, "NeoTreeDirectoryName", { fg = "#4A8494" })
set(0, "NeoTreeRootName", { fg = "#DD3014", bold = true })
set(0, "NeoTreeGitAdded", { fg = "#5B7035" })
set(0, "NeoTreeGitModified", { fg = "#D3A03B" })
set(0, "NeoTreeGitDeleted", { fg = "#DD3014" })

-- fzf-lua (Replaced Telescope)
set(0, "FzfLuaBorder", { fg = "#584958" })
set(0, "FzfLuaCursorLine", { bg = "#322932" })
set(0, "FzfLuaNormal", { bg = "#1A171C" })

-- git signs
set(0, "GitSignsAdd", { fg = "#5B7035" })
set(0, "GitSignsChange", { fg = "#D3A03B" })
set(0, "GitSignsDelete", { fg = "#DD3014" })
