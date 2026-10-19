{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.restic ];

  systemd.tmpfiles.rules = [
    "d /var/lib/apps/backups 0700 root root -"
  ];

  # Credentials for the encrypted, off-site Restic repository. The repository
  # password is deliberately kept in a separate secret file.
  age.secrets."restic-s3.env" = {
    file = ../../secrets/contabo-server/restic-s3.env.age;
    path = "/run/agenix/restic-s3.env";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  age.secrets."restic-password" = {
    file = ../../secrets/contabo-server/restic-password.age;
    path = "/run/agenix/restic-password";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # First create a consistent, logical PostgreSQL dump and a copy of Vikunja's
  # attachment directory. Restic then encrypts and uploads that staging
  # directory directly to S3. The short Vikunja stop prevents writes from
  # producing a database/files mismatch.
  systemd.services.vikunja-backup = {
    description = "Back up Vikunja to the encrypted Restic S3 repository";

    after = [
      "docker.service"
      "apps-compose.service"
      "agenix-identity.service"
      "agenix.service"
    ];

    requires = [
      "docker.service"
      "apps-compose.service"
    ];

    path = with pkgs; [ docker restic rsync coreutils ];

    environment = {
      RESTIC_PASSWORD_FILE = config.age.secrets."restic-password".path;
      XDG_CACHE_HOME = "/var/cache/vikunja-backup";
    };

    serviceConfig = {
      Type = "oneshot";
      CacheDirectory = "vikunja-backup";
      EnvironmentFile = [
        config.age.secrets."apps.env".path
        config.age.secrets."restic-s3.env".path
      ];
    };

    script = ''
      set -euo pipefail
      umask 077

      staging="$(mktemp -d /var/lib/apps/backups/vikunja.XXXXXX)"
      vikunja_stopped=0

      cleanup() {
        if [ "$vikunja_stopped" -eq 1 ]; then
          docker start apps-vikunja-1 >/dev/null 2>&1 || true
        fi
        rm -rf "$staging"
      }
      trap cleanup EXIT

      docker stop --time 30 apps-vikunja-1
      vikunja_stopped=1

      docker exec apps-postgres-1 \
        pg_dump --username "$POSTGRES_USER" --format=custom \
        --file /tmp/vikunja.pg.dump "$VIKUNJA_DATABASE_NAME"
      docker cp apps-postgres-1:/tmp/vikunja.pg.dump "$staging/vikunja.pg.dump"
      docker exec apps-postgres-1 rm /tmp/vikunja.pg.dump

      rsync -a /var/lib/apps/vikunja/files/ "$staging/files/"

      docker start apps-vikunja-1
      vikunja_stopped=0

      # A newly provisioned server initializes the repository automatically;
      # existing repositories are left untouched.
      restic cat config >/dev/null 2>&1 || restic init
      restic backup --tag vikunja "$staging"
      restic forget --prune \
        --keep-daily 7 \
        --keep-weekly 4 \
        --keep-monthly 12 \
        --keep-yearly 3
    '';
  };

  systemd.timers.vikunja-backup = {
    description = "Run the Vikunja backup every night at 01:00";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 01:00:00";
      Persistent = true;
    };
  };
}
