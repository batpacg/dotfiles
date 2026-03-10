# Configuration file for ipython.

c = get_config()

c.InteractiveShellApp.exec_PYTHONSTARTUP = False
c.TerminalIPythonApp.exec_PYTHONSTARTUP = False

c.TerminalIPythonApp.display_banner = False

c.InteractiveShellApp.exec_lines = [
    "import numpy as np",
    # Import and configurate matplotlib.
    "import matplotlib as mpl",
    "mpl.use('module://matplotlib-backend-kitty')",
    "import matplotlib.pyplot as plt",
    "from IPython import get_ipython",
    "def post_execute_plot():\n    if plt.get_fignums():\n        plt.show()",
    "get_ipython().events.register('post_execute', post_execute_plot)",
    # "plt.ion()",
    # End matplotlib configuration.
    "import sympy as sm",
    "import scipy as sc",
]

c.TerminalInteractiveShell.editing_mode = "vi"
c.TerminalInteractiveShell.editor = "nvim"
c.TerminalInteractiveShell.emacs_bindings_in_vi_insert_mode = False

c.TerminalInteractiveShell.shortcuts = [
    {
        "new_keys": ["c-s"],
        "create": True,
        "command": "IPython:shortcuts.open_input_in_editor",
    },
]
