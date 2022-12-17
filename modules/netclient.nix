{ pkgs, config, lib, ... }:

with lib;
let
  cfg = config.services.netclient;
in
{
  options = {
    services.netclient = {
      enable = mkEnableOption "Enable netmaker netclient";
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.netclient
    ];

    networking.wireguard.enable = true;

    systemd.services.netclient = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      description = "Netclient Daemon";
      documentation = [ "https://docs.netmaker.org https://k8s.netmaker.org" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.netclient}/bin/netclient daemon";
        RestartSec = "15s";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
