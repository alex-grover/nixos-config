# alex-grover/nixos-config

My nix configs.

## Getting Started (Mac)

```sh
# Install nix
curl -L https://nixos.org/nix/install | sh

# Clone repo
sudo mkdir -p /etc/nix-darwin
sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
nix-shell -p jujutsu --run jj git clone --no-colocate https://github.com/alex-grover/nixos-config.git /etc/nix-darwin

# Install nix-darwin and set up system
sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake /etc/nix-darwin#<host>
```

## Usage

```sh
# Rebuild
nh darwin switch

# Update
nh darwin switch --update
```
