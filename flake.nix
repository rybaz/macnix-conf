{
  description = "macOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:

  let
    configuration = { pkgs, ... }: {

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;
      nixpkgs.hostPlatform = "aarch64-darwin";

      nix.settings.experimental-features = "nix-command flakes";
      nix.extraOptions = '' extra-platforms = x86_64-darwin aarch64-darwin '';
      nix.linux-builder.enable = true;
      nixpkgs.config.allowUnfree = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # system config options
      # index: https://daiderd.com/nix-darwin/manual/index.html
      system.stateVersion = 5;
      system.startup.chime = false;
      system.defaults = {
        dock.autohide = true;
        dock.launchanim = false;
        dock.magnification = false;
        dock.mineffect = "scale";
        dock.mru-spaces = false;
        dock.orientation = "left";
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        loginwindow.LoginwindowText = "hunter2";
        menuExtraClock.Show24Hour = true;
        menuExtraClock.ShowDate = 1;
        menuExtraClock.ShowDayOfWeek = true;
        screencapture.disable-shadow = true;
        screencapture.location = "~/home/files/pics/screenshots";
        screensaver.askForPasswordDelay = 10;
        spaces.spans-displays = false;
      };

      # The platform the configuration will be used on.
      environment.systemPackages = with pkgs; [
        # core
        #firefox         # browser
        #killall
        #links2          # text browser
        #signal-desktop  # signal
        #zathura         # PDF reader
        alacritty
        bat
        cmus            # music
        direnv
        ffmpeg          # audio utils
        fish
        less
        mpv
        neovim          # god mode
        oh-my-posh      # zsh prompt
        pass
        ripgrep
        sox             # audio utils
        stow            # dotfile management
        tmux
        yt-dlp          # download/view YouTube in terminal
        zbar            # read QR codes
        zoxide          # "better" `cd`

        # archives
        p7zip
        unzip
        xz
        zip

        # common
        #rsync           # sync data
        curl
        fd
        feh             # image viewer
        file
        flashrom        # firmware flashing
        fzf             # A command-line fuzzy finder
        git             # for linux kernel contributions of course
        jq              # JSON parser
        tree
        wget
        which

        # system utils
        #iotop
        #ltrace
        #strace
        #usbutils
        #nix-output-monitor
        btop
        gcc
        htop
        iftop
        lsof
        pciutils

        # security
        #firejail        # isolated run environments for programs
        #wireguard-tools
        dnsutils        # `dig` + `nslookup`
        gnupg           # PGP
        nmap            # network discovery and security auditing
        pinentry-curses # terminal pin entry for pass

        # UI config and tools
        #xdg-user-dirs          # fix shitty directories for things
        #xdg-utils              # fix shitty directories for things
        #xsel                   # clipboard from X11
        imagemagick
        inconsolata-nerdfont   # good font
        pngpaste               # paste image files from clipboard
	    ];
      
      programs.zsh.enable = true;

    };
  
  in {
    darwinConfigurations."mordu" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    darwinPackages = self.darwinConfigurations."mordu".pkgs;
  };
}
