local plugins = require('lib.plugins')

plugins.use('mason-org/mason.nvim')
plugins.use('mason-org/mason-lspconfig.nvim')

require('mason').setup()
require('mason-lspconfig').setup()
