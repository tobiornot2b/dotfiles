let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcynBDS/URZLSgtWqdlwlId2sZOkcPpxNftdJwRC6zR";
  users = [ user1 ];
in
{
  "secret1.age".publicKeys = [ user1 ];
}
