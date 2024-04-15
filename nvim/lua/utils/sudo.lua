local M = {}

function M.exec(command)
  vim.fn.inputsave()
  local password = vim.fn.inputsecret('sudo: ')
  vim.fn.inputrestore()

  if not password or #password == 0 then
    return "no password"
  end

  vim.fn.system('sudo -S ' .. command, password .. '\n')

  if vim.v.shell_error ~= 0 then
    return "incorrect password"
  end
end

function M.write()
  local tmpfile = vim.fn.tempname()
  local filepath = vim.fn.expand('%:p')

  vim.cmd('silent write! ' .. tmpfile)
  local error_message = M.exec(('cp %s %s'):format(tmpfile, filepath))
  vim.fn.delete(tmpfile)

  if error_message ~= nil then
    print(error_message)
  else
    print(('"%s" written'):format(filepath))
    vim.cmd('edit!')
  end
end

return M
