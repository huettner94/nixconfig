{
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZAL4256HBJD-00BL2_S67PNE0W167896";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            primary = {
              size = "100G";
              content = {
                type = "lvm_pv";
                vg = "nvme";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      nvme = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };
}
