#!/usr/bin/env bash

# https://niri-wm.github.io/niri/Getting-Started.html

# Enable needed services
sudo systemctl enable sddm.service
systemctl --user add-wants niri.service noctalia.service
systemctl --user enable noctalia.service

# Since niri uses the gtk/gnome portal, if we prefer a dark theme we need to
# use this command.
dconf write /org/gnome/desktop/interface/color-scheme '"prefer-dark"'

# Use kitty instead of gnome-terminal.
if pacman -Qq kitty > /dev/null && [ ! -L /usr/bin/gnome-terminal ]; then
	sudo ln -s /usr/bin/kitty /usr/bin/gnome-terminal
fi
