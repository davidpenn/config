{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    mkDarwinConfiguration = {
        primaryUser ? "david",
        hostname ? null,
        hostPlatform ? "aarch64-darwin"
    }: { pkgs, config, lib, ... }: {
      users.users.${primaryUser} = {
        name = primaryUser;
        home = "/Users/${primaryUser}";
      };
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          # Cloud & Infrastructure
          pkgs.awscli
          pkgs.doppler
          pkgs.kubectl
          pkgs.kubernetes-helm
          pkgs.k9s
          pkgs.talosctl
          pkgs.tenv
          pkgs.vault

          # Backup & Storage
          pkgs.autorestic
          pkgs.restic

          # Development Tools
          pkgs.claude-code
          pkgs.git
          pkgs.gh
          pkgs.neovim
          pkgs.just
          pkgs.stow

          # Languages & Runtimes
          pkgs.fnm
          pkgs.go
          pkgs.golangci-lint
          pkgs.scala_2_12
          pkgs.sbt
          pkgs.uv

          # Data & Databases
          pkgs.databricks-cli
          pkgs.duckdb
          pkgs.postgresql
          (import ../pkgs/spark.nix { inherit pkgs; })

          # CLI Utilities
          pkgs.eza
          pkgs.fzf
          pkgs.httpie
          pkgs.jq
          pkgs.ripgrep
          pkgs.saml2aws
          pkgs.zoxide
        ];

      homebrew = {
        enable = true;
        brews = [
          "syncthing"
        ];
        casks = [
          # Security & Password Management
          "1password"
          "keybase"

          # Web Browsers
          "firefox"
          "google-chrome"
          "zen"

          # Development Tools
          "hex-fiend"
          "jetbrains-toolbox"
          "tower"
          "visual-studio-code"
          "warp"

          # Productivity & Utilities
          "keepingyouawake"
          "keyboardcleantool"
          "notion-calendar"
          "obsidian"
          "raycast"
          "setapp"

          # Communication & Media
          "audio-hijack"
          "loopback"
          "mimestream"

          # Java Runtimes
          "zulu@8"
          "zulu@17"

          # Video Conferencing
          "zoom"
        ];
      };

      system.defaults = {
        dock = {
          autohide = true;
          mineffect = "scale";
          minimize-to-application = true;
          show-recents = false;
          static-only = true;
          tilesize = 32;
        };

        finder = {
          FXPreferredViewStyle = "clmv";
        };

        NSGlobalDomain = {
          AppleICUForce24HourTime = true;
          AppleInterfaceStyle = "Dark";
          AppleShowScrollBars = "Always";
          InitialKeyRepeat = 10;
          KeyRepeat = 1;
        };

        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = false;
        };
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Optionally set hostname (only if provided)
      networking.hostName = lib.mkIf (hostname != null) hostname;

      system = {
        primaryUser = primaryUser;
        configurationRevision = self.rev or self.dirtyRev or null;
        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 6;
      };

      # Nixpkgs Configuration
      nixpkgs = {
        config.allowUnfree = true;
        hostPlatform = hostPlatform;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#<config-name>
    darwinConfigurations."ssc" = nix-darwin.lib.darwinSystem {
      modules = [
        (mkDarwinConfiguration { primaryUser = "davidpenn"; })
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.davidpenn = { pkgs, ... }: {
            imports = [ ../home ];
            programs.git = {
              settings.user.email = "dpenn@securityscorecard.io";
              signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILead31KPmdhHh/wOEQT3OCFV5xoBbVFcVgQJUSLtHwk";
            };
          };
        }
      ];
    };

    darwinConfigurations."titan" = nix-darwin.lib.darwinSystem {
      modules = [
        (mkDarwinConfiguration { hostname = "titan"; })
        {
          homebrew.casks = [
            # Development & Infrastructure
            "core-tunnel"
            "orbstack"
            "tailscale-app"

            # Productivity & Writing
            "grammarly-desktop"
            "macwhisper"

            # Finance & Trading
            "ledger-wallet"
            "tradingview"

            # Communication & Media
            "spotify"
            "whatsapp"

            # Gaming & Entertainment
            "nvidia-geforce-now"

            # Device Management
            "imazing"
          ];
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.david = import ../home;
        }
      ];
    };
  };
}
