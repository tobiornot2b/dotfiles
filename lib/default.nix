# these functions are made available under outputs.lib.my flake wide
{lib, ...}: rec {
  # taken from: https://github.com/RSWilli/nixos/blob/master/lib/default.nix
  # recursively list all modules in the given directory. The given path must be stringified because otherwise
  # it will resolve to the nix store instead of the source directory, which would break some imports/readFile calls
  listModulesRecursivly = dir: let
    entries = builtins.readDir dir;
    modules = lib.mapAttrsToList (path: _: "${toString dir}/${path}") (lib.filterAttrs (
        path: type: let
          isModule = type == "regular" && lib.hasSuffix ".nix" path && path != "default.nix";
          isDirWithDefault = type == "directory" && builtins.pathExists "${toString dir}/${path}/default.nix";
        in
          isModule || isDirWithDefault
      )
      entries);
    subdirs = lib.mapAttrsToList (path: _: "${toString dir}/${path}") (lib.filterAttrs (path: type: type == "directory") entries);
  in
    modules ++ lib.concatMap listModulesRecursivly subdirs;

  publicKey = builtins.readFile ../static/willi-id_ed25519.pub;

  initrd-ssh-host-pubkey = builtins.readFile ../static/initrd-ssh-host-key.pub;
}
