{ config, pkgs, lib, ... }:

{
  home.stateVersion = "24.11";

  home.file = {
    "${config.xdg.configHome}/zsh.d".source = ./zsh.d;
    "${config.xdg.configHome}/git/allowed_signers".text = ''
      david.penn@me.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFgbwoqV/UFX81s+MzciX05LJFltkE8z28KuDbTYbb5
      dpenn@securityscorecard.io ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILead31KPmdhHh/wOEQT3OCFV5xoBbVFcVgQJUSLtHwk
    '';
  };

  home.sessionVariables = {

  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
    };
  };

  programs.git = {
    enable = true;
    ignores = [
      # Claude Code
      "**/.claude/settings.local.json"
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"
      ".DocumentRevisions-V100"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".VolumeIcon.icns"
      ".com.apple.timemachine.donotpresent"
      ".AppleDB"
      ".AppleDesktop"
      "Network Trash Folder"
      "Temporary Items"
      ".apdisk"
    ];
    includes = [
      {
        condition = "hasconfig:remote.*.url:git@github.com:securityscorecard/**";
        contents = {
          user = {
            email = "dpenn@securityscorecard.io";
            "signingKey" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILead31KPmdhHh/wOEQT3OCFV5xoBbVFcVgQJUSLtHwk";
          };
        };
      }
    ];
    settings = {
      alias = {
        # View abbreviated SHA, description, and history graph of the latest 20 commits
        l = "log --color --decorate --pretty=format:'%C(auto)%h -%d %s %C(green)(%cr) %C(blue) %an%C(reset)' -n 20 --abbrev-commit";
        lg = "!git l --graph";

        # View the current working tree status using the short format
        s = "status -s";

        # Show verbose output about tags, branches or remotes
        tags = "tag -l";
        branches = "branch -a";
        remotes = "remote -v";

        # Amend the currently staged files to the latest commit
        amend = "commit --amend --reuse-message=HEAD";

        # Remove branches that have already been merged with master
        # a.k.a. ‘delete merged’
        dm = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d; git remote update -p";

        # List contributors with number of commits
        contributors = "shortlog --summary --numbered";
      };
      apply.whitespace = "fix";
      core = {
      	# Treat spaces before tabs and all kinds of trailing whitespace as an error
      	# [default] trailing-space: looks for spaces at the end of a line
      	# [default] space-before-tab: looks for spaces before tabs at the beginning of a line
        whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";

        # Make `git rebase` safer on OS X
        # More info: <http://www.git-tower.com/blog/make-git-rebase-safe-on-osx/>
        trustctime = false;

        editor = "nvim";
        pager = "less -FRX";
      };
      color.ui = "auto";
      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
          program = lib.mkIf pkgs.stdenv.isDarwin "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
      };
      push = {
        autoSetupRemote = true;

        # Push only the current branch if its named upstream is identical
        default = "simple";
      };
      url."git@github.com:".insteadOf = "https://github.com/";
      user = {
        name = "David Penn";
        email = "david.penn@me.com";
      };
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFgbwoqV/UFX81s+MzciX05LJFltkE8z28KuDbTYbb5";
      signByDefault = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreAllDups = true;
      ignoreSpace = true;
      ignoreDups = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "aws" "command-not-found" ];
    };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    initContent = "test -d ${config.xdg.configHome}/zsh.d && source <(cat $HOME/.config/zsh.d/*.sh)";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
