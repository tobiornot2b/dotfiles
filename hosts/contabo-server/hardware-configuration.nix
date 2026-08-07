# Hardware configuration for contabo-server
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "virtio_pci"
    "virtio_blk"
  ];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  swapDevices = [];

  networking.usePredictableInterfaceNames = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
