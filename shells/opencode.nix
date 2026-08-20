{ pkgs }:

let
  headroomSetup = pkgs.writeShellScriptBin "headroom-setup" ''
    exec uv tool install --python 3.13 --force "headroom-ai[all]" "$@"
  '';
in
pkgs.mkShell {
  packages = with pkgs; [
    opencode
    nodejs
    bun
    git
    uv
    python313
    python313Packages.pip
    headroomSetup
  ];

  shellHook = ''
    export OPENCODE_DEV_HOME="$PWD/.dev-home"
    export HOST_HOME="''${HOME}"
    export HOME="$OPENCODE_DEV_HOME"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_STATE_HOME="$HOME/.local/state"
    export UV_TOOL_DIR="$XDG_DATA_HOME/uv/tools"
    export UV_TOOL_BIN_DIR="$HOME/.local/bin"
    export PATH="$UV_TOOL_BIN_DIR:$PATH"

    mkdir -p \
      "$XDG_CONFIG_HOME" \
      "$XDG_DATA_HOME" \
      "$XDG_CACHE_HOME" \
      "$XDG_STATE_HOME" \
      "$UV_TOOL_BIN_DIR"

    OPENCODE_GLOBAL_SKILLS="/home/dwp7953/.agents/skills"
    OPENCODE_LOCAL_SKILLS="$HOME/.agents/skills"
    if [ -d "$OPENCODE_GLOBAL_SKILLS" ]; then
      mkdir -p "$OPENCODE_LOCAL_SKILLS"
      cp -a "$OPENCODE_GLOBAL_SKILLS/." "$OPENCODE_LOCAL_SKILLS/"
      echo "OpenCode devshell: globale Skills eingebunden"
    else
      echo "OpenCode devshell: keine globalen Skills gefunden"
    fi

    OPENCODE_CONFIG_SKILLS="$HOST_HOME/.config/opencode/skills"
    OPENCODE_LOCAL_CONFIG_SKILLS="$XDG_CONFIG_HOME/opencode/skills"
    if [ -d "$OPENCODE_CONFIG_SKILLS" ]; then
      mkdir -p "$OPENCODE_LOCAL_CONFIG_SKILLS"
      cp -a "$OPENCODE_CONFIG_SKILLS/." "$OPENCODE_LOCAL_CONFIG_SKILLS/"
      echo "OpenCode devshell: konfigurationsbasierte Skills eingebunden"
    else
      echo "OpenCode devshell: keine konfigurationsbasierten Skills gefunden"
    fi

    OPENCODE_AUTH_FILE="$HOST_HOME/.local/share/opencode/auth.json"
    if [ -r "$OPENCODE_AUTH_FILE" ]; then
      export OPENCODE_AUTH_CONTENT="$(<"$OPENCODE_AUTH_FILE")"
      echo "OpenCode devshell: bestehende Credentials lesend eingebunden"
    else
      echo "OpenCode devshell: keine bestehende auth.json gefunden"
    fi

    unset OPENCODE_AUTH_FILE
    unset OPENCODE_GLOBAL_SKILLS
    unset OPENCODE_LOCAL_SKILLS
    unset OPENCODE_CONFIG_SKILLS
    unset OPENCODE_LOCAL_CONFIG_SKILLS
    unset HOST_HOME
  '';
}
