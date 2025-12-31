# Update the nix flake
update:
    nix flake update --flake ./nix/darwin

# Rebuild and switch to the new darwin configuration
switch:
    sudo darwin-rebuild switch --flake ./nix/darwin#$(hostname -s)