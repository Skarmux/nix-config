{ config, ... }:
{
  sops.secrets."ssh/id_ecdsa_sk" = {
    sopsFile = ../../secrets.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_ecdsa_sk";
  };

  sops.secrets."ssh/known_hosts" = {
    sopsFile = ../../secrets.yaml;
    path = "${config.home.homeDirectory}/.ssh/known_hosts";
  };

  home.file = {
    ".ssh/id_ecdsa_sk.pub".source = ../../yubikey/id_ecdsa_sk.pub;
  };
}
