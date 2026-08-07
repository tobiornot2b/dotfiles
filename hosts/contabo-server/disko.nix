# Disk layout for contabo-server (BIOS/Legacy boot + LUKS encryption)
#
# Partition scheme: GPT (required by disko — MBR/msdos is not supported)
# Even though this is a BIOS/Legacy boot system (not UEFI), GPT is used.
# GRUB supports GPT on BIOS via a dedicated 1MB "BIOS boot" partition (type EF02).
# Disko automatically sets boot.loader.grub.devices based on this partition —
# do NOT set boot.loader.grub.device manually in default.nix, it causes a
# "duplicated devices in mirroredBoots" assertion failure.
#
# Partition layout:
#   sda1  1M      EF02  BIOS boot (no filesystem, used by GRUB internally)
#   sda2  512M    ext4  /boot
#   sda3  100%    LUKS2 cryptroot → ext4  /
#
# LUKS key during nixos-anywhere install:
#   The keyFile path (/tmp/contabo-luks-key) refers to the file on the TARGET
#   machine. nixos-anywhere uploads the local key file to that path before
#   running disko. After installation the key is wiped automatically.
#   On first boot the LUKS passphrase must be entered via VNC/KVM console.
#   See README.md § "nixos-anywhere: Remote NixOS Installation" for the full
#   procedure.
{
  disko.devices = {
    disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          # 1MB BIOS boot partition — required for GRUB to work on a GPT disk
          # without UEFI. Has no filesystem; GRUB embeds its core image here.
          bios = {
            size = "1M";
            type = "EF02";
          };
          # Unencrypted /boot — GRUB cannot read LUKS2 by default, so /boot
          # must live outside the encrypted partition.
          boot = {
            size = "512M";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
            };
          };
          # Encrypted root partition (LUKS2)
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              # Remote path where nixos-anywhere uploads the local key file.
              # Pass the local file with:
              #   --disk-encryption-keys /tmp/contabo-luks-key /path/to/local/keyfile
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
