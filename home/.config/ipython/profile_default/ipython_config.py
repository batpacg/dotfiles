#
# Configuration file for ipython.
#

config = get_config()

config.InteractiveShellApp.exec_PYTHONSTARTUP = False
config.TerminalIPythonApp.exec_PYTHONSTARTUP = False

config.TerminalIPythonApp.display_banner = False

config.InteractiveShellApp.exec_lines = [
    "import numpy as np",
    "import matplotlib.pyplot as plt",
    "import scipy as sc",
    "import sympy as sm",
    "sm.init_printing(use_unicode=True)",
    "s, t, x, y, z = sm.symbols('s t x y z')",
]

config.TerminalInteractiveShell.editing_mode = "vi"
config.TerminalInteractiveShell.emacs_bindings_in_vi_insert_mode = False

config.TerminalInteractiveShell.editor = "nvim"
config.TerminalInteractiveShell.shortcuts = [
    {
        "new_keys": ["c-s"],
        "create": True,
        "command": "IPython:shortcuts.open_input_in_editor",
    },
]
