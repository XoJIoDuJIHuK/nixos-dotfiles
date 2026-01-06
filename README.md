# Installation on clean system

Was tested on ISO 26.05 with GNOME default DE on install (when choosing no DE option for some reason Nix could not build Quickshell: clang failed with segfault)

Choose GNOME as DE (easier to find and fix issues is they arise) and execute

```sh
nix-shell -p git
git clone https://github.com/XoJIoDuJIHuK/nixos-dotfiles .dotfiles
mkcd -p .dotfiles/homes/${desired_hostname} # must not be occupied by another folder. Currently only options nixos and nixos-intel are supported, and for new ones new entries in flake.nix are required. Defining them is pretty straightforward
cp /etc/nixos/hardware-configuration.nix .
sudo nixos-rebuild switch --flake .dotfiles#nixos # for nvidia GPU
sudo nixos-rebuild switch --flake .dotfiles#nixos-intel # for intel integrated card
```


Probably reboot. This should suffice

## TODO

1. Implement proper MAIN SHIFT Q screen (currently no styling)
2. Add more info to Quickshell dashboards (for instance, specific numbers of resources consumption)
3. Create sing-box wrapper (service or app) to appear in caelestia bar(s)
