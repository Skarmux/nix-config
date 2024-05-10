# Shell for bootstrapping flake-enabled nix and other tooling
{ pkgs ? # If pkgs is not defined, instanciate nixpkgs from locked commit
  let
    lock =
      (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in import nixpkgs { overlays = [ ]; }, ... }: {
    default = pkgs.mkShell {
      NIX_CONFIG =
        "extra-experimental-features = nix-command flakes repl-flake";
      GPG_TTY="$(tty)";
      nativeBuildInputs = with pkgs; [
        nix
        nixfmt-classic
        home-manager
        git
        nil # nix lsp

        deploy-rs

        sops
        ssh-to-age
        gnupg
        age
      ];
    };
  }
