-- When calling `:edit` from autocommands, it seems like Neovim fails to
-- properly "setup" the file. For example, the filetype will not be set and
-- `BufEnter` events will fail to fire.
--
-- To fix this, we edit the file immediately, then update it on Neovim's next
-- tick to ensure the buffer is setup properly.
--
-- TODO: Report this to Neovim? Not sure if this is a bug...
return function(file)
  file = file or ''
  vim.cmd('edit ' .. file)
  vim.schedule(function() vim.cmd('edit ' .. file) end)
end
