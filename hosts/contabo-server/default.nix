{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # Bootloader for BIOS/MBR
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hostname
  networking.hostName = "contabo-server";

  # Networking: static IPv4
  networking.useDHCP = false;
  networking.interfaces.eth0 = {
    ipv4.addresses = [
      {
        address = "62.84.178.194";
        prefixLength = 20;
      }
    ];
  };
  networking.defaultGateway = "62.84.176.1";
  networking.nameservers = [ "195.179.224.53" "209.126.15.53" ];

  # Time zone
  time.timeZone = "Europe/Berlin";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable SSH
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "/etc/ssh/ssh_host_ed25519_key";
    }
  ];

  # SSH key for root login (public key)
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZCMZVo8DvBYJRl0ksZsqYAn8MbCcZwUOQ7K8rZ7Vk/ tobias@dwp7953"
  ];

  # Enable systemd
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;

  # Minimal packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    iotop
    netcat
    curl
    wget
  ];

  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
}
