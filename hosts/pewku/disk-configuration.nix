{
  disko.devices = {

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "size=512M"
        "mode=755"
        "noexec"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content.type = "mbr";
      content.partitions = {

        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };

        swap = {
          size = "4G";
          content = {
            type = "swap";
          };
        };

        nixos = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/nix";
          };
        };

      };
    };
  };
}
