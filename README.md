# Installation on clean system

Was tested on ISO 26.05 with GNOME default DE on install (when choosing no DE option Nix for some reason could not build Quickshell: clang failed with segfault)

Choose GNOME as DE (easier to find and fix issues is they arise)

```sh
nix-shell -p git
git clone https://github.com/XoJIoDuJIHuK/nixos-dotfiles .dotfiles
cp /etc/nixos/hardware-configuration.nix .dotfiles/
sudo nixos-rebuild switch --flake .dotfiles#nixos # for nvidia
sudo nixos-rebuild switch --flake .dotfiles#nixos-intel # for nvidia
```

