{ config, lib, pkgs, ... }:

let
  tobiTokenFile = "/run/agenix/gh-token-tobiornot2b";
  omtoTokenFile = "/run/agenix/gh-token-omtomedical";
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

  # Default `gh` account is omtomedical (used for all omtomedical/* repos).
  # `gh-tobi` below is a separate wrapper for tobiornot2b/* repos.
  # Populates hosts.yml from the agenix-decrypted token at activation time
  # instead of storing it in home.nix / the Nix store.
  home.activation.ghAuth = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${omtoTokenFile}" ]; then
      TOKEN="$(cat "${omtoTokenFile}")"
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

  # Plain `git` (clone/push/pull) picks its token by the remote's org, so it
  # works correctly regardless of which account `gh` currently has active.
  programs.git = {
    enable = true;
    settings = {
      credential."https://github.com/omtomedical" = {
        helper = "!f() { echo \"username=x-access-token\"; echo \"password=$(cat ${omtoTokenFile})\"; }; f";
      };
      credential."https://github.com/tobiornot2b" = {
        helper = "!f() { echo \"username=x-access-token\"; echo \"password=$(cat ${tobiTokenFile})\"; }; f";
      };
    };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "gh-tobi" ''
      export GH_TOKEN="$(cat ${tobiTokenFile})"
      exec ${pkgs.gh}/bin/gh "$@"
    '')
  ];
}
