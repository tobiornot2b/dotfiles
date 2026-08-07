{
  disko.devices = {
    disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "mbr";
        partitions = {
          boot = {
            type = "83";
            size = "512M";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
            };
          };
          root = {
            type = "83";
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              keyFile = "/tmp/contabo-luks-key";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
