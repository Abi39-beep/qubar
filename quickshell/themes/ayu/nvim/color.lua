local set = vim.api.nvim_set_hl

vim.cmd("hi clear")

-- base
set(0, "Normal", { fg = "#e5e1cf", bg = "#0e1419" })
set(0, "CursorLine", { bg = "#243340" })
set(0, "LineNr", { fg = "#555555" })
set(0, "CursorLineNr", { fg = "#e5e1cf" })

-- syntax
set(0, "Comment", { fg = "#555555", italic = true })
set(0, "String", { fg = "#b8cc52" })
set(0, "Function", { fg = "#36a3d9" })
set(0, "Keyword", { fg = "#f07078" })
set(0, "Type", { fg = "#e6c446" })

-- diagnostics
set(0, "DiagnosticError", { fg = "#ff3333" })
set(0, "DiagnosticWarn", { fg = "#e6c446" })
set(0, "DiagnosticInfo", { fg = "#36a3d9" })
set(0, "DiagnosticHint", { fg = "#95e5cb" })

-- neo-tree (Replaces NvimTree)
set(0, "NeoTreeNormal", { bg = "#0e1419" })
set(0, "NeoTreeNormalNC", { bg = "#0e1419" })
set(0, "NeoTreeDirectoryName", { fg = "#36a3d9" })
set(0, "NeoTreeRootName", { fg = "#f07078", bold = true })
set(0, "NeoTreeGitAdded", { fg = "#b8cc52" })
set(0, "NeoTreeGitModified", { fg = "#e6c446" })
set(0, "NeoTreeGitDeleted", { fg = "#ff3333" })

-- fzf-lua (Replaces Telescope)
set(0, "FzfLuaBorder", { fg = "#555555" })
set(0, "FzfLuaCursorLine", { bg = "#243340" })
set(0, "FzfLuaNormal", { bg = "#0e1419" })

-- git signs
set(0, "GitSignsAdd", { fg = "#b8cc52" })
set(0, "GitSignsChange", { fg = "#e6c446" })
set(0, "GitSignsDelete", { fg = "#ff3333" })
