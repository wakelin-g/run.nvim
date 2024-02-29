# run.nvim

Extremely simple plugin for running code without leaving neovim. Press `<C-b>` (by default) to trigger `<cmd>Run<cr>`, displaying the code output in a window on the right side of the screen. This window will then be updated automatically every time the file is saved.

![image](https://github.com/wakelin-g/run.nvim/assets/86983768/2b3388f0-7d6c-41fb-82ef-2b000594d4b9)

Run commands are currently hard-coded but with support for C, C++, Python, Rust, Go, and Lua via:

- ["c"] = `clang % && ./a.out`
- ["cpp"] = `clang++ % && ./a.out`
- ["py"] = `python3 %`
- ["rs"] = `cargo run %`
- ["go"] = `go run %`
- ["lua"] = `lua %`
