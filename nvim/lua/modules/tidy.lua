-- Tidy
-- Modified version of https://github.com/mcauley-penney/tidy.nvim

vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'bsuth',
  callback = function(args)
    local cursor = vim.api.nvim_win_get_cursor(0)

    vim.cmd([[keepjumps keeppatterns %s/\s\+$//e]])                   -- trailing whitespace
    vim.cmd([[keepjumps keeppatterns silent! 0;/^\%(\n*.\)\@!/,$d_]]) -- trailing newlines

    cursor[1] = math.min(cursor[1], vim.api.nvim_buf_line_count(args.buf))
    vim.api.nvim_win_set_cursor(0, cursor)
  end,
})
