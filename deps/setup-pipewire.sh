#!/usr/bin/env bash

# Enable needed services
systemctl --user enable wireplumber.service
systemctl --user enable pipewire.service
systemctl --user enable pipewire-pulse.service
