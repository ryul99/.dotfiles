-- overall keybinding
vim.keymap.set(
  { "n", "x" },
  "<localleader>x",
  "<cmd>JupyniumExecuteSelectedCells<CR>",
  { buffer = buf_id, desc = "Jupynium execute selected cells" }
)
vim.keymap.set(
  { "n", "x" },
  "<localleader>c",
  "<cmd>JupyniumClearSelectedCellsOutputs<CR>",
  { buffer = buf_id, desc = "Jupynium clear selected cells" }
)
vim.keymap.set(
  { "n" },
  "<localleader>k",
  "<cmd>JupyniumKernelHover<cr>",
  { buffer = buf_id, desc = "Jupynium hover (inspect a variable)" }
)
vim.keymap.set(
  { "n", "x" },
  "<localleader>js",
  "<cmd>JupyniumScrollToCell<cr>",
  { buffer = buf_id, desc = "Jupynium scroll to cell" }
)
vim.keymap.set(
  { "n", "x" },
  "<localleader>jo",
  "<cmd>JupyniumToggleSelectedCellsOutputsScroll<cr>",
  { buffer = buf_id, desc = "Jupynium toggle selected cell output scroll" }
)
vim.keymap.set(
  { "n", "x" },
  "<localleader>s",
  "<cmd>JupyniumSaveIpynb<cr>",
  { buffer = buf_id, desc = "Jupynium save ipynb" }
)
vim.keymap.set("", "<PageUp>", "<cmd>JupyniumScrollUp<cr>", { buffer = buf_id, desc = "Jupynium scroll up" })
vim.keymap.set("", "<PageDown>", "<cmd>JupyniumScrollDown<cr>", { buffer = buf_id, desc = "Jupynium scroll down" })

-- textobj keybinding
vim.keymap.set(
    { "n", "x", "o" },
    "[j",
    "<cmd>lua require'jupynium.textobj'.goto_previous_cell_separator()<cr>",
    { buffer = buf_id, desc = "Go to previous Jupynium cell" }
)
  vim.keymap.set(
    { "n", "x", "o" },
    "]j",
    "<cmd>lua require'jupynium.textobj'.goto_next_cell_separator()<cr>",
    { buffer = buf_id, desc = "Go to next Jupynium cell" }
)
  vim.keymap.set(
    { "n", "x", "o" },
    "<localleader>jj",
    "<cmd>lua require'jupynium.textobj'.goto_current_cell_separator()<cr>",
    { buffer = buf_id, desc = "Go to current Jupynium cell" }
)
  vim.keymap.set(
    { "x", "o" },
    "aj",
    "<cmd>lua require'jupynium.textobj'.select_cell(true, false)<cr>",
    { buffer = buf_id, desc = "Select around Jupynium cell" }
)
  vim.keymap.set(
    { "x", "o" },
    "ij",
    "<cmd>lua require'jupynium.textobj'.select_cell(false, false)<cr>",
    { buffer = buf_id, desc = "Select inside Jupynium cell" }
)
  vim.keymap.set(
    { "x", "o" },
    "aJ",
    "<cmd>lua require'jupynium.textobj'.select_cell(true, true)<cr>",
    { buffer = buf_id, desc = "Select around Jupynium cell (include next cell separator)" }
)
  vim.keymap.set(
    { "x", "o" },
    "iJ",
    "<cmd>lua require'jupynium.textobj'.select_cell(false, true)<cr>",
    { buffer = buf_id, desc = "Select inside Jupynium cell (include next cell separator)" }
)
