{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  config = mkIf (config.securix.self.machine.hardwareSKU == "framework13-gen12") {
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    hardware.firmware = [
      # WiFi
      pkgs.linux-firmware
      pkgs.wireless-regdb
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    services.throttled.enable = lib.mkDefault false;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
