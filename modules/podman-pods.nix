{ lib, config, ... }:
let
  cfg = config.podman-pods;
  exampleContainers = {
    # FIXME: Does this example even work?
    app = {
      image = "docker.io/gitea/gitea";
      environment = {
        GITEA__database__DB_TYPE = "postgres";
        GITEA__database__HOST = "127.0.0.1:5432";
        GITEA__database__NAME = "gitea";
        GITEA__database__USER = "gitea";
        GITEA__database__PASSWD = "gitea";
      };
      volumes = [
        "/var/lib/gitea:/data"
        "/etc/localtime:/etc/localtime:ro"
        "/etc/timezone:/etc/timezone:ro"
      ];
    };
    db = {
      image = "docker.io/postgres";
      environment = {
        POSTGRES_USER = "gitea";
        POSTGRES_PASSWORD = "gitea";
        POSTGRES_DB = "gitea";
      };
    };
  };
  podOptions.options = {
    ip = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = lib.mdDoc "Ip of pod";
      example = "10.10.8.3";
    };
    ports = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = lib.mdDoc "Port mappings to publish on localhost";
      example = [ "1234:2563" ];
    };
    containers = lib.mkOption {
      type = lib.types.attrs;
      description = lib.mdDoc "List of containers in this pod compatible with virtualisation.oci-containers.containers";
      example = exampleContainers;
    };
  };
in
{
  options = {
    podman-pods.pods = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (lib.types.submodule podOptions);
      description = lib.mdDoc "List of pods";
      example = {
        gitea = {
          ports = [
            "3000:3000"
            "22:22"
          ];
          containers = exampleContainers;
        };
      };
    };
  };
  # NOTE: mkMerge causes infinite recusion at the top level so need to write this mental gymnastics code
  config = lib.mkIf (cfg.pods != { }) {
    virtualisation.oci-containers.containers =
      let
        groupedContainers = lib.mapAttrsToList (podName: options: { inherit podName; containers = options.containers; }) cfg.pods;
        expandContainers = podName: containers: lib.mapAttrs'
          (k: v: {
            name = "${podName}-${k}";
            value = v // {
              extraOptions = (v.extraOptions or [ ]) ++ [ "--pod=${podName}" ];
            };
          })
          containers;
      in
      lib.foldl' (acc: x: acc // (expandContainers x.podName x.containers)) { } groupedContainers;

    systemd.services = lib.mapAttrs'
      (podName: options: {
        name = "podman-${podName}-create-pod";
        value =
          let
            podman = "${config.virtualisation.podman.package}/bin/podman";
          in
          {
            serviceConfig.Type = "oneshot";
            wantedBy = map (name: "podman-${podName}-${name}.service") (lib.attrNames options.containers);
            preStart = ''
              ${podman} pod rm --force ${podName} || true
            '';
            script = lib.concatStringsSep " \\\n "
              ([
                "${podman} pod create"
                "--name ${podName}"
              ]
              ++ map (port: "--publish 127.0.0.1:${port}") options.ports
              ++ lib.optional (options.ip != null) "--ip ${options.ip}");
          };
      })
      cfg.pods;
  };
}
