
-- Feline statusline definition.
--
-- Note: This statusline does not define any colors. Instead the statusline is
-- built on custom highlight groups that I define. The colors for these
-- highlight groups are pulled from the current colorscheme applied. Check the
-- file: `lua/eden/modules/ui/colors.lua` to see how they are defined.

local fmt = string.format

local file_info_component = {
    provider = {
        name = 'file_info',
        opts = {
            type = 'full-path'
        }
    },
    short_provider = {
        name = 'file_info',
        opts = {
            type = 'short-path'
        }
    }
}


local c = {
 fileinfo = {
    provider = { name = "file_info", opts = { type = "full-path" } },
  },
    in_fileinfo = {
    provider = "file_info",
  },
  in_position = {
    provider = "position",
  },
}

local active = {
  { -- left
    c.fileinfo,
  },
}

local inactive = {
  { c.in_fileinfo }, -- left
  { c.in_position }, -- right
}

-- -- Define autocmd that generates the highlight groups from the new colorscheme
-- -- Then reset the highlights for feline
-- edn.aug.FelineColorschemeReload = {
--   {
--     { "SessionLoadPost", "ColorScheme" },
--     function()
--       require("eden.modules.ui.feline.colors").gen_highlights()
--       -- This does not look like it is required. If this is called I see the ^^^^^^ that
--       -- seperates the two sides of the bar. Since the entire config uses highlight groups
--       -- all that is required is to redefine them.
--       -- require("feline").reset_highlights()
--     end,
--   },
-- }

require("feline").setup()

require('feline').winbar.setup{
  components = { active = active, inactive = inactive },
}

