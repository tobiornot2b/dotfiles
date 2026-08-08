{ config, lib, ... }:

let
  tokenFile = "/run/agenix/gh-token-tobiornot2b";
in
{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      aliases.co = "pr checkout";
    };
  };

  # gh was set up manually before this module existed, so config.yml
  # already exists on disk and needs to be handed over to home-manager.
  xdg.configFile."gh/config.yml".force = true;

  # Populates hosts.yml from the agenix-decrypted token at activation time
  # instead of storing it in home.nix / the Nix store.
  home.activation.ghAuth = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${tokenFile}" ]; then
      TOKEN="$(cat "${tokenFile}")"
      install -Dm600 /dev/null "$HOME/.config/gh/hosts.yml"
      cat > "$HOME/.config/gh/hosts.yml" <<EOF
github.com:
    users:
        tobiornot2b:
            oauth_token: $TOKEN
    git_protocol: https
    oauth_token: $TOKEN
    user: tobiornot2b
EOF
    fi
  '';
}
