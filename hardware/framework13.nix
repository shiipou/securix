# SPDX-FileCopyrightText: 2026 Sécurix project authors
#
# SPDX-License-Identifier: MIT

# Framework Laptop 13" — 12th Gen Intel Core (Alder Lake-P, board FRANGACP06)
# Based on nixos-hardware framework/13-inch/12th-gen-intel and its imported
# common modules (framework/13-inch/common + framework/13-inch/common/intel).
# Kernel-version-gated workarounds skipped: we use linuxPackages_latest (≥ 6.8).
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = lib.mkIf (config.securix.self.machine.hardwareSKU == "framework13") {
    # Use a recent kernel — Framework 13 benefits from fixes landed after 6.1.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Power saving.
    boot.kernelParams = [
      # Reduce NVMe power consumption.
      # https://community.frame.work/t/linux-battery-life-tuning/6665/156
      "nvme.noacpi=1"
    ];

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];

    # Early KMS for the boot splash on Iris Xe + brightness keys.
    boot.initrd.kernelModules = [ "i915" ];

    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # cros-usbpd-charger is not used on Framework but causes boot-time
    # error logs.
    boot.blacklistedKernelModules = [ "cros-usbpd-charger" ];

    # Intel AX210/AX211 Wi-Fi + Bluetooth firmware.
    hardware.firmware = [
      pkgs.linux-firmware
      pkgs.wireless-regdb
    ];

    # VA-API hardware video decode for Iris Xe.
    hardware.graphics.extraPackages = [
      pkgs.intel-media-driver
      pkgs.vpl-gpu-rt
    ];

    # Brightness detection by desktop environments.
    hardware.sensor.iio.enable = lib.mkDefault true;

    # nixos-generate-config mis-detects the backlight interface.
    # https://github.com/NixOS/nixpkgs/issues/171093
    hardware.acpilight.enable = lib.mkDefault true;

    # NVMe health.
    services.fstrim.enable = lib.mkDefault true;

    # Fingerprint reader.
    services.fprintd.enable = lib.mkDefault true;

    # Custom udev rules for Framework hardware.
    services.udev.extraRules = ''
      # Fix headphone jack intermittent noise.
      # https://community.frame.work/t/headphone-jack-intermittent-noise/5246/55
      SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0xa0e0", ATTR{power/control}="on"

      # Ethernet expansion card power saving.
      # https://github.com/NixOS/nixos-hardware/blob/master/framework/13-inch/common
      ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", ATTR{power/autosuspend}="20"
    '';

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Framework EC tool for interacting with the embedded controller.
    environment.systemPackages = lib.optional (pkgs ? "fw-ectool") pkgs.fw-ectool;
  };
}
