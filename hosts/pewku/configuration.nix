{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    # inputs.hardware.nixosModules.raspberry-pi-4
    # inputs.impermanence.nixosModules.impermanence
    # inputs.disko.nixosModules.disko
    # ./disk-configuration.nix
    ../common/global/locale.nix
  ];

  users = {
    mutableUsers = false;
    users = {
      skarmux = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        initialPassword = "monster6";
        openssh.authorizedKeys.keyFiles = [
          ../../home/skarmux/yubikey/id_ed25519.pub
          ../../home/skarmux/yubikey/id_ecdsa_sk.pub
        ];
      };
    };
  };

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      grub.enable = false;
    };
    kernelParams = [ 
      "console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0" "cma=64M"
    ];
    initrd.availableKernelModules = [
      # Allows early (earlier) modesetting for the Raspberry Pi
      "vc4"
      "bcm2835_dma"
      "i2c_bcm2835"
      
      # Maybe needed for SSD boot?
      "usb_storage"
      "xhci_pci"
      "usbhid"
      "uas"
    ];
    supportedFilesystems = [ "bcachefs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  services = {
    # Enable fan controller from Argon One Case
    hardware.argonone.enable = true;
    openssh = {
      enable = true;
      allowSFTP = false;
      settings = {
        Compression = "yes";
        AllowTcpForwarding = "yes";
        AllowAgentForwarding = "no";
        AllowStreamLocalForwarding = "no";
        AuthenticationMethods = "publickey";
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        StreamLocalBindUnlink = "yes";
        AllowUsers = [ "skarmux" ];
      };
    };
    tailscale.enable = true;
  };

  nixpkgs.hostPlatform.system = "aarch64-linux";

  # Only users of wheels group can use nix package manager daemon
  nix.settings.allowed-users = [ "@wheel" ];

  powerManagement.cpuFreqGovernor = "ondemand";

  networking = {
    hostName = "pewku";
    wireless.enable = false;
    firewall = {
      enable = true;
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      # allowedTCPPorts = [ 80 443 ];
    };
  };

  security = {
    sudo.execWheelOnly = true;
    auditd.enable = true;
    # Use `journalctl -f` to see audit logs
    audit = {
      enable = true;
      rules = [
        # Log every time a program is attempted to be run.
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
  };

  environment = {
    # Prevent default packages from being installed
    systemPackages = lib.mkForce [ ];

    # etc = {
    #   "ssh/ssh_host_rsa_key".source = "/nix/persist/etc/ssh/ssh_host_rsa_key";
    #   "ssh/ssh_host_rsa_key.pub".source = "/nix/persist/etc/ssh/ssh_host_rsa_key.pub";
    #   "ssh/ssh_host_ed25519_key".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
    #   "ssh/ssh_host_ed25519_key.pub".source = "/nix/persist/etc/ssh/ssh_host_ed25519_key.pub";
    #   "machine-id".source = "/nix/persist/etc/machine-id";
    # };

    # persistence."/nix/persist" = {
    #   directories = [
    #     "/var/lib"
    #     "/var/log"
    #     "/etc/nixos"
    #     "/srv"
    #   ];
    # };
  };

  fileSystems = {
    "/" = {
      device = "/dev/sda2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/sda1";
      fsType = "fat32";
    };
    # "/var/lib".options = [ "noexec" ];
    # "/var/log".options = [ "noexec" ];
    # "/etc/nixos".options = [ "noexec" ];
    # "/srv".options = [ "noexec" ];
  };

  # hardware.raspberry-pi."4".i2c1.enable = true;

  system.stateVersion = "24.05";
}
