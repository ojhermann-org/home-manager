{ lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    # The jump-box entry is Darwin-only: the jump box itself does not need
    # an SSM proxy to connect to itself.
    matchBlocks = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
      };
      "jump-box" = {
        # HostName is unused by the ProxyCommand; the command resolves the
        # instance ID dynamically by tag so no config change is needed when
        # the instance is replaced.
        hostname = "jump-box";
        user = "otto";
        identityFile = "~/.ssh/id_ed25519";
        # Looks up the running instance by the Name tag at connection time,
        # then tunnels SSH through SSM — no inbound port 22 required.
        proxyCommand = ''sh -c "aws ssm start-session --target \$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=shared-jump-box-management' 'Name=instance-state-name,Values=running' --query 'Reservations[0].Instances[0].InstanceId' --output text --profile otto-management) --document-name AWS-StartSSHSession --parameters 'portNumber=%p' --profile otto-management"'';
        extraOptions = {
          # Accept the host key on first connection; subsequent connections
          # verify against the saved key in ~/.ssh/known_hosts.
          StrictHostKeyChecking = "accept-new";
        };
      };
    };
  };

  # `jump` is Darwin-only: it connects to the jump box via SSH over SSM.
  programs.zsh.shellAliases = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    jump = "ssh jump-box";
  };
}
