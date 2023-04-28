{ inputs, pkgs, lib, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_hardened;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  nix = {
    # Adicionar flake inputs no registry
    registry = builtins.mapAttrs (_name: value: { flake = value; }) inputs;
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
    };
    settings = {
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    hostPlatform = "x86_64-linux";
    overlays = [(self: super: {
      mtprotoproxy = super.mtprotoproxy.overrideAttrs (oldattrs: {
        src = self.fetchFromGitHub {
          owner = "alexbers";
          repo = "mtprotoproxy";
          rev = "v1.1.1";
          sha256 = "sha256-tQ6e1Y25V4qAqBvhhKdirSCYzeALfH+PhNtcHTuBurs=";
        };
      });
    })];
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      permitRootLogin = "no";
      ports = [ 2112 ];
    };
  };

  users = {
    mutableUsers = false;
    users = {
      admin = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = import ../../keys.nix;
        initialPassword = "correcthorsebatterystaple";
      };
    };
  };

  # Sudo sem senha
  security.sudo.extraConfig = "%wheel ALL = (ALL) NOPASSWD: ALL";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "pt_BR.UTF-8";
    };
  };

  time.timeZone = "America/Sao_Paulo";
  system.stateVersion = "21.11";
}
