{ lib, pkgs, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  programs.ssh = {
    enable = true;
    matchBlocks = {
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
}
