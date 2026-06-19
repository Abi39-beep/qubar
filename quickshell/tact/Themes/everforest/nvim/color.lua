local set = vim.api.nvim_set_hl

vim.cmd("hi clear")

-- base
set(0, "Normal", { fg = "#D3C6AA", bg = "#272E33" })
set(0, "CursorLine", { bg = "#343F44" }) -- A subtle dark grey for the cursor line
set(0, "LineNr", { fg = "#7A8478" })     -- color8 (Bright Black / Grey)
set(0, "CursorLineNr", { fg = "#D3C6AA" })
set(0, "Visual", { bg = "#4C3743" })     -- Mapped from your selection_background!

-- syntax
set(0, "Comment", { fg = "#7A8478", italic = true }) -- color8
set(0, "String", { fg = "#A7C080" })                  -- color2 (Green)
set(0, "Function", { fg = "#7FBBB3" })                -- color4 (Blue)
set(0, "Keyword", { fg = "#E67E80" })                 -- color1 (Red)
set(0, "Type", { fg = "#DBBC7F" })                    -- color3 (Yellow)

-- diagnostics
set(0, "DiagnosticError", { fg = "#E67E80" })         -- color1 (Red)
set(0, "DiagnosticWarn", { fg = "#DBBC7F" })          -- color3 (Yellow)
set(0, "DiagnosticInfo", { fg = "#7FBBB3" })          -- color4 (Blue)
set(0, "DiagnosticHint", { fg = "#83C092" })          -- color6 (Cyan/Aqua)

-- neo-tree
set(0, "NeoTreeNormal", { bg = "#272E33" })
set(0, "NeoTreeNormalNC", { bg = "#272E33" })
set(0, "NeoTreeDirectoryName", { fg = "#7FBBB3" })
set(0, "NeoTreeRootName", { fg = "#E67E80", bold = true })
set(0, "NeoTreeGitAdded", { fg = "#A7C080" })
set(0, "NeoTreeGitModified", { fg = "#DBBC7F" })
set(0, "NeoTreeGitDeleted", { fg = "#E67E80" })

-- fzf-lua
set(0, "FzfLuaBorder", { fg = "#7A8478" })
set(0, "FzfLuaCursorLine", { bg = "#343F44" })
set(0, "FzfLuaNormal", { bg = "#272E33" })

-- git signs
set(0, "GitSignsAdd", { fg = "#A7C080" })
set(0, "GitSignsChange", { fg = "#DBBC7F" })
set(0, "GitSignsDelete", { fg = "#E67E80" })
