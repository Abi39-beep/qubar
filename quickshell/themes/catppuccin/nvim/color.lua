local set = vim.api.nvim_set_hl

vim.cmd("hi clear")

-- base
set(0, "Normal", { fg = "#cdd6f4", bg = "#1e1e2e" })
set(0, "CursorLine", { bg = "#313244" })
set(0, "LineNr", { fg = "#6c7086" })
set(0, "CursorLineNr", { fg = "#cdd6f4" })

-- syntax
set(0, "Comment", { fg = "#6c7086", italic = true })
set(0, "String", { fg = "#a6e3a1" })
set(0, "Function", { fg = "#89b4fa" })
set(0, "Keyword", { fg = "#cba6f7" })
set(0, "Type", { fg = "#f9e2af" })

-- diagnostics
set(0, "DiagnosticError", { fg = "#f38ba8" })
set(0, "DiagnosticWarn", { fg = "#f9e2af" })
set(0, "DiagnosticInfo", { fg = "#89b4fa" })
set(0, "DiagnosticHint", { fg = "#94e2d5" })

-- neo-tree (Replaces NvimTree)
set(0, "NeoTreeNormal", { bg = "#1e1e2e" })
set(0, "NeoTreeNormalNC", { bg = "#1e1e2e" })
set(0, "NeoTreeDirectoryName", { fg = "#89b4fa" })
set(0, "NeoTreeRootName", { fg = "#cba6f7", bold = true })
set(0, "NeoTreeGitAdded", { fg = "#a6e3a1" })
set(0, "NeoTreeGitModified", { fg = "#f9e2af" })
set(0, "NeoTreeGitDeleted", { fg = "#f38ba8" })

-- fzf-lua (Replaces Telescope)
set(0, "FzfLuaBorder", { fg = "#585b70" })
set(0, "FzfLuaCursorLine", { bg = "#313244" })
set(0, "FzfLuaNormal", { bg = "#1e1e2e" })

-- git signs
set(0, "GitSignsAdd", { fg = "#a6e3a1" })
set(0, "GitSignsChange", { fg = "#f9e2af" })
set(0, "GitSignsDelete", { fg = "#f38ba8" })
