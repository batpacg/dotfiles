#!/usr/bin/env bash

flatpak override --user --env=XCOMPOSEFILE=$HOME/.XCompose
flatpak override --user --env=GTK_IM_MODULE=xim
flatpak override --user --filesystem=~/.XCompose:ro
