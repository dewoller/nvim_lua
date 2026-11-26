return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 && cmake --build build --config Release",
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff",  "<cmd>Telescope find_files<cr>",        desc = "find_files" },
      { "<leader>fr",  "<cmd>Telescope live_grep<cr>",         desc = "live_grep" },
      { "<leader>b",   "<cmd>Telescope buffers<cr>",           desc = "buffers" },
      { "<leader>fh",  "<cmd>Telescope help_tags<cr>",         desc = "help_tags" },
      { "<Leader>fo",  "<cmd>Telescope oldfiles<CR>",          desc = "oldfiles" },
      { "<leader>fF",  function() vim.api.nvim_command("Telescope git_files default_text=" .. vim.fn.expand("<cword>")) end, desc = "git_files word" },
      { "<leader>gf",  function() vim.api.nvim_command("edit " .. vim.fn.expand("<cword>")) end, desc = "edit cword" },
      { "<leader>fw",  function() vim.api.nvim_command("Telescope live_grep default_text=" .. vim.fn.expand("<cword>")) end, desc = "live_grep word" },
      { "<leader>jR",  "<cmd>Telescope lsp_references<cr>",       desc = "lsp_references" },
      { "<leader>jD",  "<cmd>Telescope lsp_definitions<cr>",      desc = "lsp_definitions" },
      { "<leader>ji",  "<cmd>Telescope lsp_incoming_calls<cr>",   desc = "lsp_incoming_calls" },
      { "<leader>jo",  "<cmd>Telescope lsp_outgoing_calls<cr>",   desc = "lsp_outgoing_calls" },
      { "<leader>gt",  "<cmd>Telescope git_commits<cr>",          desc = "git_commits" },
      { "<leader>gs",  "<cmd>Telescope git_status<cr>",           desc = "git_status" },
      { "<leader>tc",  "<cmd>Telescope colorscheme<cr>",          desc = "colorscheme" },
      { "<leader>tq",  "<cmd>Telescope quickfix<cr>",             desc = "quickfix" },
      { "<leader>th",  "<cmd>Telescope quickfixhistory<cr>",      desc = "quickfixhistory" },
      { "<leader>tl",  "<cmd>Telescope loclist<cr>",              desc = "loclist" },
      { "<leader>ts",  "<cmd>Telescope search_history<cr>",       desc = "search_history" },
      { "<leader>tr",  "<cmd>Telescope resume<cr>",               desc = "telescope resume" },
      { "<leader>to",  "<cmd>Telescope vim_options<cr>",          desc = "vim_options" },
      { "<leader>tm",  "<cmd>Telescope marks<cr>",                desc = "marks" },
      { "<leader>tk",  "<cmd>Telescope keymaps<cr>",              desc = "keymaps" },
      { "<leader>ta",  "<cmd>Telescope autocommands<cr>",         desc = "autocommands" },
      { "<bslash>",    "<cmd>Telescope buffers<cr>",              mode = { "n", "v" } },
    },
    config = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case",
          },
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = { mirror = false },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          file_ignore_patterns = { "node_modules" },
          path_display = { "truncate" },
          winblend = 0,
          borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
          color_devicons = true,
          set_env = { ["COLORTERM"] = "truecolor" },
          mappings = {
            n = {
              ["<c-d>"] = actions.delete_buffer,
              ["q"]     = actions.close,
            },
            i = {
              ["<C-h>"] = "which_key",
              ["<c-d>"] = actions.delete_buffer,
            },
          },
        },
        pickers = {
          buffers = {
            ignore_current_buffer = true,
            sort_lastused = true,
          },
        },
      })
      require("telescope").load_extension("fzf")
    end,
  },
}
