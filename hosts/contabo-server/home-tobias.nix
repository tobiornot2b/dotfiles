{ config, pkgs, lib, ... }:

{
  imports = [
    ../../home/core.nix
  ];
  # Minimal home manager configuration for server
  home.stateVersion = "24.11";

  # nono profile scoping Claude Code's sandbox to the omto checkout.
  # Extends the registry pack's base "claude" profile (cwd + ~/.claude +
  # network + tty) with read/write access to the repo regardless of the
  # invoking shell's cwd. Usage: nono run --profile omto -- claude
  xdg.configFile."nono/profiles/omto.json".text = builtins.toJSON {
    extends = "nolabs-ai/claude";
    filesystem.allow = [ "/home/tobias/sources/omto" ];
  };

  # Registry packs aren't Nix-managed, so pull the base pack imperatively
  # at activation time (mirrors the gh-auth activation script in
  # home/gh.nix). Safe to re-run; failures (e.g. no network yet) don't
  # break activation.
  home.activation.nonoPullClaudePack = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.nono}/bin/nono pull nolabs-ai/claude || true
  '';
}
