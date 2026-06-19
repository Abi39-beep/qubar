local set = vim.api.nvim_set_hl

vim.cmd("hi clear")

-- base
set(0, "Normal", { fg = "#d4be98", bg = "#282828" })
set(0, "CursorLine", { bg = "#32302f" })
set(0, "LineNr", { fg = "#7c6f64" })
set(0, "CursorLineNr", { fg = "#d4be98" })

-- syntax
set(0, "Comment", { fg = "#928374", italic = true })
set(0, "String", { fg = "#a9b665" })
set(0, "Function", { fg = "#89b482" })
set(0, "Keyword", { fg = "#ea6962" })
set(0, "Type", { fg = "#d8a657" })

-- diagnostics
set(0, "DiagnosticError", { fg = "#ea6962" })
set(0, "DiagnosticWarn", { fg = "#d8a657" })
set(0, "DiagnosticInfo", { fg = "#7daea3" })
set(0, "DiagnosticHint", { fg = "#89b482" })

-- neo-tree (Replaced NvimTree)
set(0, "NeoTreeNormal", { bg = "#282828" })
set(0, "NeoTreeNormalNC", { bg = "#282828" })
set(0, "NeoTreeDirectoryName", { fg = "#7daea3" })
set(0, "NeoTreeRootName", { fg = "#ea6962", bold = true })
set(0, "NeoTreeGitAdded", { fg = "#a9b665" })
set(0, "NeoTreeGitModified", { fg = "#d8a657" })
set(0, "NeoTreeGitDeleted", { fg = "#ea6962" })

-- fzf-lua (Replaced Telescope)
set(0, "FzfLuaBorder", { fg = "#504945" })
set(0, "FzfLuaCursorLine", { bg = "#32302f" })
set(0, "FzfLuaNormal", { bg = "#282828" })

-- git signs
set(0, "GitSignsAdd", { fg = "#a9b665" })
set(0, "GitSignsChange", { fg = "#d8a657" })
set(0, "GitSignsDelete", { fg = "#ea6962" })
