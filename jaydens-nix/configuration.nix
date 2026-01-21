# Edit this configuration file to define what should be installed on your system. Help is available
# in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # Enable Flakes

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest; # Install the latest kernel

  # Hardware stuff

  hardware.bluetooth = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.graphics.enable = true; # Enable OpenGL

  services.xserver.videoDrivers = ["nvidia"]; # Load nvidia driver for Xorg and Wayland

  hardware.nvidia = {
    modesetting.enable = true;  # Modesetting is required
    open = true;
    nvidiaSettings = false; # Enable the Nvidia settings menu, accessible via `nvidia-settings`
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = { # Enable Nvidia Optimus with sync mode
      sync.enable = true;
      amdgpuBusId = "PCI:6:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  networking.hostName = "jaydens-nix"; # Define your hostname.
  networking.networkmanager.enable = true;  # Enable networking

  time.timeZone = "America/Boise";  # Set your time zone

  i18n.defaultLocale = "en_US.UTF-8"; # Select internationalisation properties
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  users.users.jblackman199 = {  # Define a user account. Don't forget to set a password with ‘passwd’
    isNormalUser = true;
    description = "Jayden Blackman";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish; # Make fish the default shell
  };

  system.autoUpgrade = {
    enable = true; # Automatically upgrade
    randomizedDelaySec = "30sec"; # Raise upgrade attempts
  };

  nix.gc = { # Collect garbage weekly
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise.automatic = true; # Automatically optimize /nix/store weekly
  nix.optimise.dates = [ "weekly" ];

  # List services that you want to enable:

  services.flatpak.enable = true; # Enable flatpak

  services.desktopManager.plasma6.enable = true;  # Enable Plasma 6
  services.displayManager = {
    defaultSession = "plasma"; # Set default session plasma = wayland, plasmax11 = x11
    sddm.enable = true; # Enable SDDM
    sddm.wayland.enable = true; # Set SDDM to Wayland
    sddm.autoNumlock = true;  # Enable numlock on SDDM
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [  # Exclude listed packages
    elisa
    khelpcenter
    krdp
    oxygen
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # for electron wayland

  services.xserver = {  # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  services.printing.enable = true;  # Enable CUPS to print documents

  services.tailscale.enable = true; # Install and enable tailscale

  nixpkgs.config.allowUnfree = true;  # Allow unfree packages

  environment.systemPackages = with pkgs; [ # List packages installed in system profile. To search, run: nix search wget
    airshipper
    brave
    fastfetch
    fwupd
    git
    hunspell
    hunspellDicts.en_US
    hyphen
    kdePackages.discover
    kdePackages.dolphin-plugins
    kdePackages.ffmpegthumbs
    kdePackages.isoimagewriter
    kdePackages.kasts
    kdePackages.kate
    kdePackages.kdeconnect-kde
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kde-gtk-config
    kdePackages.kimageformats
    kdePackages.partitionmanager
    kdePackages.plasma-browser-integration
    kdePackages.print-manager
    kdePackages.qtimageformats
    kdePackages.sddm-kcm
    kdePackages.sonnet
    kdePackages.svgpart
    libreoffice-qt6-fresh
    mythes
    qalculate-gtk
    rnote
    rssguard
    signal-desktop
    superTuxKart
    thunderbird
    ventoy
    vlc
    xdg-desktop-portal-gtk
    xournalpp
  ];

  fonts.packages = with pkgs; [ # List fonts installed
    liberation_ttf
    libertine
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-lgc-plus
    noto-fonts-monochrome-emoji
    unicode-emoji
  ];

  programs.steam.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ # Let nonfree Steam dependencies work
    "steam"
    "steam-original"
    "steam-run"
    "teams"
  ];
  
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.07"];

  networking.firewall = { # Open ports for KDE Connect
    enable = true;
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];
  };

  programs.fish.enable = true;  # Enable Fish

  programs.dconf.enable = true; # Fix GTK themes

  # programs.mtr.enable = true; # Some programs need SUID wrappers, can be configured further or are started in user sessions.
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default settings for stateful data,
  # like file locations and database versions on your system were taken. It‘s perfectly fine
  # and recommended to leave this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
