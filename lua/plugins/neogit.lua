return {
  {
    "NeogitOrg/neogit",
    branch = "master",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Neogit",
    keys = {
      { "<LocalLeader>rg", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
    opts = {
      disable_commit_confirmation = true,
    },
  },
}
