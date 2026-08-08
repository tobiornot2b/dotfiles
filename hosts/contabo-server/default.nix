{ config, pkgs, ... }:

let
  adminSshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZCMZVo8DvBYJRl0ksZsqYAn8MbCcZwUOQ7K8rZ7Vk/ tobias@dwp7953"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6yNUxV27Kg/MucDGJEE7GMySzNLvH7HK98DgX4gJY1 tobias.maede@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6hDIfFCmsCmX8dj+9CsZJpwYrJ2TohSkyL8IQnfxeU tobias.taschenberger@MN-EXLRFJ470Y77"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  nixpkgs.config.allowUnfree = true;

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

  # SSH: root login disabled entirely, password authentication disabled.
  # Admin access goes through the "tobias" user (wheel + passwordless sudo)
  # below. If that ever breaks, use Contabo's rescue console to fix it —
  # there is no other way in (no password, no root SSH).
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.hostKeys = [
    {
      type = "ed25519";
      path = "/etc/ssh/ssh_host_ed25519_key";
    }
  ];

  # Kept so PermitRootLogin can be flipped back to "prohibit-password" for
  # emergency access without hunting down keys again; inert while "no".
  users.users.root.openssh.authorizedKeys.keys = adminSshKeys;

  # Unprivileged admin user: sudo (wheel) + docker group, key-only login.
  # No password is set anywhere on this host, so sudo trusts the SSH key
  # that got you in rather than prompting for a password you don't have.
  users.users.tobias = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = adminSshKeys;
  };
  security.sudo.wheelNeedsPassword = false;

  # Disable sleep/suspend — not meaningful on a headless server
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;

  # Install terminfo entries for common terminal emulators (incl. Ghostty's
  # xterm-ghostty) so SSH sessions from them render correctly without the
  # manual `infocmp -x | ssh ... tic -x -` fix from ghostty.org/docs/help/terminfo.
  environment.enableAllTerminfo = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    gh
    htop
    iotop
    netcat
    curl
    wget
    docker
    docker-compose
    claude-code
    # nono comes from the llm-agents-nix flake input (see flake.nix) — not nixpkgs
  ];

  # Docker
  virtualisation.docker.enable = true;

  # Firewall: allow HTTP and HTTPS for Traefik
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # Create directories for containerized applications
  systemd.tmpfiles.rules = [
    "d /var/lib/apps 0755 root root -"
    "d /var/lib/apps/vikunja 0755 root root -"
    "d /var/lib/apps/vikunja/files 0777 root root -"
    "d /var/lib/apps/postgres 0755 root root -"
    "d /var/lib/apps/postgres/data 0777 root root -"
    "d /var/lib/apps/letsencrypt 0755 root root -"
    "f /var/lib/apps/letsencrypt/acme.json 0600 root root -"
  ];

  # agenix secrets
  age.secrets."apps.env" = {
    file = ../../secrets/contabo-server/apps.env.age;
    path = "/var/lib/apps/.env";
    owner = "root";
    group = "root";
    mode = "0600";
  };

  age.secrets."gh-token-tobiornot2b" = {
    file = ../../secrets/contabo-server/gh-token-tobiornot2b.age;
    owner = "tobias";
    group = "root";
    mode = "0400";
  };

  # Deploy Docker Compose file to /etc
  environment.etc."apps/docker-compose.yaml".source = ./server/docker-compose.yaml;

  # systemd service for containerized applications stack
  systemd.services.apps-compose = {
    description = "Docker Compose applications stack";

    wantedBy = [ "multi-user.target" ];

    after = [
      "docker.service"
      "network-online.target"
      "agenix-identity.service"
      "agenix.service"
    ];

    wants = [
      "docker.service"
      "network-online.target"
    ];

    restartTriggers = [
      ./server/docker-compose.yaml
      config.age.secrets."apps.env".path
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/apps";

      ExecStart =
        "${pkgs.docker-compose}/bin/docker-compose "
        + "--env-file ${config.age.secrets."apps.env".path} "
        + "-f /etc/apps/docker-compose.yaml "
        + "up --detach --remove-orphans";

      ExecStop =
        "${pkgs.docker-compose}/bin/docker-compose "
        + "--env-file ${config.age.secrets."apps.env".path} "
        + "-f /etc/apps/docker-compose.yaml "
        + "down";
    };
  };

  # Enable Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
}
