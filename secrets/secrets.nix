# agenix rules: maps each encrypted `.age` file to the public keys allowed to
# decrypt it. Edit secrets with `agenix -e <name>.age` from this directory
# (agenix reads this file to know who to encrypt for). Decryption uses the
# matching private key listed in `age.identityPaths` (see programs/agenix.nix).
let
  # Otto's SSH key, used as both the encryption recipient and (via its private
  # half at ~/.ssh/id_ed25519) the decryption identity at activation time.
  otto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII5hpaZcGtfgHIvJ66KhRwVJmT7KDolQBoF1hBoslsg8 ojhermann@gmail.com";
in
{
  "slack-bot-token.age".publicKeys = [ otto ];
  "gh-getlora-token.age".publicKeys = [ otto ];
}
