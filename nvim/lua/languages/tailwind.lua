-- -----------------------------------------------------------------------------
-- LSP
-- -----------------------------------------------------------------------------

vim.lsp.enable('tailwindcss', true)
vim.lsp.config('tailwindcss', {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = { 'gleam' },
  root_markers = { 'gleam.toml', '.git' },
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = { "\"([^\"]*)\"" },
      },
      includeLanguages = {
        gleam = "html",
      },
    },
  },
})
