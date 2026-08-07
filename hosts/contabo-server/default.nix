{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # Bootloader: BIOS/Legacy boot with GPT disk (via disko).
  # Do NOT set boot.loader.grub.device here — disko auto-configures
  # boot.loader.grub.devices from the EF02 BIOS boot partition in disko.nix.
  # Setting it manually causes a "duplicated devices in mirroredBoots" error.
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = false;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hostname
  networking.hostName = "contabo-server";

  # Static IPv4 networking — Contabo VPS does not use DHCP reliably.
  # Update address/gateway/nameservers when reprovisioning a different server.
  # Gateway is the /20 subnet gateway for the 62.84.176.0/20 range.
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
  networking.nameservers = [ "195.179.224.53" "209.126.15.53" ]; # Contabo DNS

  # Time zone
  time.timeZone = "Europe/Berlin";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # SSH: key-only root login, password authentication disabled.
  # Add your public key to authorizedKeys before deploying — there is no
  # other way in after installation (no password, no console login via SSH).
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "/etc/ssh/ssh_host_ed25519_key";
    }
  ];

  # Authorized SSH public keys for root
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZCMZVo8DvBYJRl0ksZsqYAn8MbCcZwUOQ7K8rZ7Vk/ tobias@dwp7953"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6yNUxV27Kg/MucDGJEE7GMySzNLvH7HK98DgX4gJY1 tobias.maede@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6hDIfFCmsCmX8dj+9CsZJpwYrJ2TohSkyL8IQnfxeU tobias.taschenberger@MN-EXLRFJ470Y77"
  ];

  # Disable sleep/suspend — not meaningful on a headless server
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;

  # Minimal server packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    iotop
    netcat
    curl
    wget
    docker
    docker-compose
  ];

  # Docker
  virtualisation.docker.enable = true;

  # Firewall: allow HTTP and HTTPS for Traefik
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # Create directories for Vikunja
  systemd.tmpfiles.rules = [
    "d /var/lib/vikunja 0755 root root -"
    "d /var/lib/vikunja/files 0777 root root -"
    "d /var/lib/vikunja/letsencrypt 0755 root root -"
    "d /var/lib/vikunja/postgres 0777 root root -"
    "f /var/lib/vikunja/letsencrypt/acme.json 0600 root root -"
  ];

  # Deploy Vikunja Compose file to /etc
  environment.etc."vikunja/compose.yaml".source = ./server/vikunja-compose.yaml;

  # systemd service for Vikunja Compose stack
  systemd.services.vikunja-compose = {
    description = "Vikunja Docker Compose stack";

    wantedBy = [ "multi-user.target" ];

    after = [
      "docker.service"
      "network-online.target"
    ];

    wants = [
      "docker.service"
      "network-online.target"
    ];

    restartTriggers = [
      ./server/vikunja-compose.yaml
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/vikunja";

      ExecStart =
        "${pkgs.docker-compose}/bin/docker-compose "
        + "--env-file /var/lib/vikunja/.env "
        + "-f /etc/vikunja/compose.yaml "
        + "up --detach --remove-orphans";

      ExecStop =
        "${pkgs.docker-compose}/bin/docker-compose "
        + "--env-file /var/lib/vikunja/.env "
        + "-f /etc/vikunja/compose.yaml "
        + "down";
    };
  };

  # Enable Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
}
