# run.nvim

An extremely simple plugin for running code without leaving neovim.

## Usage

`run.nvim` exports two functions:

- `RunRun` finds the filetype of the current buffer and matches it to code you have specified in your config, executes it, and displays the output in a split opened to the right. Calling `RunRun` again _or_ saving the file will re-execute the code, updating the output buffer.

  - If you have specified multiple commands for a given filetype in your config, the first call to `RunRun` will ask you to choose one of them. Subsequent calls, however, will respect your previous choice.

- `RunSwitch` allows you to change the command that `RunRun` will execute, given that there are multiple commands for a given filetype specified in your config.

If you use the default configuration, or pass `use_default_bindings = true` to the setup function, you can use `<C-b>` to execute a filetype-specific predesignated code segment and display the results in a window opened to the right of your current buffer. Each time you save your file, the code segment will be automatically re-executed.

![showcase2](showcase2.gif)

You can close the window that opens by navigating to it and pressing `q`.

## Requirements

- neovim nightly (tested with `v0.10.0-dev-2488+g5d4e1693c`)

## Installation

The default configuration is shown below.

```lua
-- lazy
{
    "wakelin-g/run.nvim",
    event = "VeryLazy",
    config = function()
        require("run").setup()
    end,
}
```

## Configuration

You can configure `run.nvim` by passing a table to `require("run").setup()` in your lazy plugin table. The following are the default options:

```lua
...
config = function()
    require("run").setup({
        use_default_bindings = true,
        output_msg = " -- OUTPUT -- ",
        win_width = 40,
        set_wrap = false,
        commands = {},
    })
end,
...
```

- `use_default_bindings` (bool) : if true, maps `<C-b>` (control + b) `:Run`, which executes the filetype-specific command. **Note**: If you set this to false, you can instead bind the run command to a key of your choice as follows:

```lua
    vim.keymap.set("n", "<YOUR-KEY-HERE", "<cmd>Run<CR>", { silent = true, noremap = true })
```

- `output_msg` (string) : message displayed at the top of the run window.

- `win_width` (integer) : width of opened window (in character cells).

- `set_wrap` (bool) : if true, wraps text of output buffer.

- `commands` (table) : table of commands in `["<filetype>"] = { "<command1>", "<command2>", ... }` format, where `"<command>"` denotes the command that will be executed when `:Run` is called from a buffer with detected filetype of `["<filetype>"]`.
  - If you are unsure of how neovim perceives your filetype of interest, enter a buffer of this filetype and execute `:lua print(vim.filetype.match({ buf = vim.api.nvim_get_current_buf() }))`. As an example, your table might look something like:

```lua
{
    ["c"] = { "clang " .. vim.fn.expand("%") .. " && ./a.out" },
    ["cpp"] = { "clang++ " .. vim.fn.expand("%") .. " && ./a.out", "gcc-13 " .. vim.fn.expand("%") .. " && ./a.out" },
    ["python"] = { "python " .. vim.fn.expand("%"), "python3 " .. vim.fn.expand("%") },
    ["rust"] = { "cargo run" },
    ["go"] = { "go run " .. vim.fn.expand("%") },
    ["lua"] = { "lua " .. vim.fn.expand("%") },
    -- add more custom commands here! ex:
    -- ["sh"] = { "bash " .. vim.fn.expand("%") }
}
```
