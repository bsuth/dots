#!/usr/bin/env python3

import os
import pynvim

NVIM_LISTEN_ADDRESS = os.environ.get('NVIM_LISTEN_ADDRESS')

if NVIM_LISTEN_ADDRESS:
    nvim = pynvim.attach('socket', path=NVIM_LISTEN_ADDRESS)
    nvim.command(f'cd {os.getcwd()}')
    nvim.command('lua save_term_cwd()')
