let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6yNUxV27Kg/MucDGJEE7GMySzNLvH7HK98DgX4gJY1";
  contabo_server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1GhgdpQvvo5RCrDsZurua5yfKDMg64fQbZ4HYq5pdG";
  users = [ user1 ];
  hosts = [ contabo_server ];
in
{
  "secret1.age".publicKeys = [ user1 ];
  "contabo-server/apps.env.age".publicKeys = hosts ++ users;
  "contabo-server/gh-token-tobiornot2b.age".publicKeys = hosts ++ users;
  "contabo-server/gh-token-omtomedical.age".publicKeys = hosts ++ users;
}
