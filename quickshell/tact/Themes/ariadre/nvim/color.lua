local set = vim.api.nvim_set_hl

vim.cmd("hi clear")

-- base
set(0, "Normal", { fg = "#f5e2c5", bg = "#040e0d" })
set(0, "CursorLine", { bg = "#0f211f" })
set(0, "LineNr", { fg = "#5a4d3e" })
set(0, "CursorLineNr", { fg = "#f5e2c5" })

-- syntax
set(0, "Comment", { fg = "#c4b09a", italic = true })
set(0, "String", { fg = "#7ad9a8" })
set(0, "Function", { fg = "#3dd1b0" })
set(0, "Keyword", { fg = "#ff6048" })
set(0, "Type", { fg = "#f5cd5b" })

-- diagnostics
set(0, "DiagnosticError", { fg = "#ff6048" })
set(0, "DiagnosticWarn", { fg = "#f5cd5b" })
set(0, "DiagnosticInfo", { fg = "#5fc8d4" })
set(0, "DiagnosticHint", { fg = "#3dd1b0" })

-- neo-tree
set(0, "NeoTreeNormal", { bg = "#040e0d" })
set(0, "NeoTreeNormalNC", { bg = "#040e0d" })
set(0, "NeoTreeDirectoryName", { fg = "#5fc8d4" })
set(0, "NeoTreeRootName", { fg = "#ff6048", bold = true })
set(0, "NeoTreeGitAdded", { fg = "#7ad9a8" })
set(0, "NeoTreeGitModified", { fg = "#f5cd5b" })
set(0, "NeoTreeGitDeleted", { fg = "#ff6048" })

-- fzf-lua
set(0, "FzfLuaBorder", { fg = "#1d3631" })
set(0, "FzfLuaCursorLine", { bg = "#0f211f" })
set(0, "FzfLuaNormal", { bg = "#040e0d" })

-- git signs
set(0, "GitSignsAdd", { fg = "#7ad9a8" })
set(0, "GitSignsChange", { fg = "#f5cd5b" })
set(0, "GitSignsDelete", { fg = "#ff6048" })
