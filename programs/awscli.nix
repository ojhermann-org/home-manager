{ pkgs, lib, ... }:

let
  mkProfile = accountId: {
    sso_session = "otto";
    sso_account_id = accountId;
    sso_role_name = "AdministratorAccess";
    region = "us-east-1";
    output = "json";
  };

  accounts = {
    management = "324621155013";
    dev = "916868258956";
    stage = "039914330850";
    prod = "425924866611";
  };
in
{
  home.packages = [
    pkgs.awscli2
  ];

  home.file.".aws/config".text = lib.generators.toINI { } (
    {
      "sso-session otto" = {
        sso_start_url = "https://d-906606f3df.awsapps.com/start/#";
        sso_region = "us-east-1";
        sso_registration_scopes = "sso:account:access";
      };
    }
    // lib.mapAttrs' (name: id: lib.nameValuePair "profile otto-${name}" (mkProfile id)) accounts
  );
}
