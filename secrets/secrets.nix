let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6yNUxV27Kg/MucDGJEE7GMySzNLvH7HK98DgX4gJY1";
  users = [ user1 ];
in
{
  "secret1.age".publicKeys = [ user1 ];
}
