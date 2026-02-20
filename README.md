# alex-grover/nixos-config

My nix configs.

## Getting Started

```sh
# Clone repo
sudo mkdir -p /etc/nix-darwin
sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
git clone https://github.com/alex-grover/nixos-config.git /etc/nix-darwin

# Install nix
curl -L https://nixos.org/nix/install | sh

# Install nix-darwin and set up system
sudo nix run nix-darwin/nix-darwin-25.11#darwin-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake /etc/nix-darwin#work
```

## Usage

```sh
# Rebuild
nh darwin switch

# Update
nh darwin switch --update
```
