# Hardware configuration for contabo-server (KVM/QEMU virtual machine)
#
# Generated manually based on the Contabo VPS hardware profile.
# If reprovisioning, run `nixos-generate-config --root /mnt` after disko
# partitioning and replace this file with the output at
# /mnt/etc/nixos/hardware-configuration.nix.
#
# IMPORTANT: fileSystems and swapDevices are intentionally omitted here.
# They are generated and managed by the disko module (disko.nix).
# Adding them here would cause a "conflicting definition values" evaluation
# error because disko uses /dev/disk/by-partlabel paths while
# nixos-generate-config emits /dev/sdaX paths.
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

  # fileSystems and swapDevices are managed by disko — do not add them here.

  networking.usePredictableInterfaceNames = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
