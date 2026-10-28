require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- pick changed file(s) and commit: <Tab> stages/unstages, <CR> stages current file + prompts for message
map("n", "<leader>gc", function()
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  require("telescope.builtin").git_status {
    prompt_title = "Git Add + Commit",
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then
          return
        end

        local out = vim.fn.system { "git", "add", "--", entry.path }
        if vim.v.shell_error ~= 0 then
          vim.notify(out, vim.log.levels.ERROR)
          return
        end

        vim.ui.input({ prompt = "Commit message: " }, function(msg)
          if not msg or msg == "" then
            vim.notify("Commit aborted (file left staged)", vim.log.levels.WARN)
            return
          end
          out = vim.fn.system { "git", "commit", "-m", msg }
          vim.notify(out, vim.v.shell_error == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
        end)
      end)
      return true
    end,
  }
end, { desc = "git add + commit" })
