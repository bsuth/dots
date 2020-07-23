package.path = package.path .. (';%s/nvim/?.lua'):format(os.getenv('DOTS'))
nvim = vim.api

require 'options'
require 'plugins'
require 'mappings'
require 'buffers'
