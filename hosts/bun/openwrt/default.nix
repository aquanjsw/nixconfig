{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.rag.services.openwrt;
  fv = "${lib.getOutput "fd" pkgs.OVMF}/FV";
  code = "${fv}/OVMF_CODE.fd";
  varsSrc = "${fv}/OVMF_VARS.fd";
  varsDst = "/var/lib/openwrt/OVMF_VARS.fd";
in
{
  options.rag.services.openwrt = {
    enable = lib.mkEnableOption "OpenWRT VM";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.openwrt = {
      description = "OpenWRT VM Router";
      after = [
        "network.target"
        "sys-subsystem-net-devices-tap0.device"
        "sys-subsystem-net-devices-tap1.device"
      ];
      wants = [
        "network.target"
      ];
      before = [
        "network-online.target"
      ];
      wantedBy = [
        "multi-user.target"
        "network-online.target"
      ];
      serviceConfig = {
        Restart = "on-failure";
        RuntimeDirectory = "openwrt";
        StateDirectory = "openwrt";
        ExecStop = ''
          echo '{"execute": "qmp_capabilities"}{"execute": "system_powerdown"}' \
            | ${pkgs.socat}/bin/socat - UNIX-CONNECT:$QMP
        '';
        TimeoutStopSec = 10;
      };
      preStart = ''
        if ! [ -f ${varsDst} ]; then
          cp ${varsSrc} ${varsDst}
        fi
      '';
      script = builtins.readFile ./start.sh;
      environment = {
        OVMF_CODE = code;
        OVMF_VARS = varsDst;
        IMAGE = "/var/lib/openwrt/openwrt-25.12.5-x86-64-generic-ext4-combined-efi.qcow2";
        SERIAL = "/run/openwrt/serial.sock";
        QMP = "/run/openwrt/qmp.sock";
        QEMU = "${pkgs.qemu_kvm}/bin/qemu-kvm";
      };
    };
  };
}
