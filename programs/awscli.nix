{ pkgs, lib, ... }:

{
  home.packages = [
    pkgs.awscli2
  ];

  home.file.".aws/config".text = lib.generators.toINI { } {
    "sso-session otto" = {
      sso_start_url = "https://d-906606f3df.awsapps.com/start/#";
      sso_region = "us-east-1";
      sso_registration_scopes = "sso:account:access";
    };
    "profile otto-management" = {
      sso_session = "otto";
      sso_account_id = "324621155013";
      sso_role_name = "AdministratorAccess";
      region = "us-east-1";
      output = "json";
    };
    "profile otto-dev" = {
      sso_session = "otto";
      sso_account_id = "916868258956";
      sso_role_name = "AdministratorAccess";
      region = "us-east-1";
      output = "json";
    };
    "profile otto-stage" = {
      sso_session = "otto";
      sso_account_id = "039914330850";
      sso_role_name = "AdministratorAccess";
      region = "us-east-1";
      output = "json";
    };
    "profile otto-prod" = {
      sso_session = "otto";
      sso_account_id = "425924866611";
      sso_role_name = "AdministratorAccess";
      region = "us-east-1";
      output = "json";
    };
  };
}
