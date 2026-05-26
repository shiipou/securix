# SPDX-FileCopyrightText: 2026 Sécurix project authors
#
# SPDX-License-Identifier: MIT

# Framework Laptop 13" — 12th Gen Intel Core (Alder Lake-P, board FRANGACP06)
# Generated from a live system; kernel modules verified on NixOS.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  config = lib.mkIf (config.securix.self.machine.hardwareSKU == "framework13") {
    # Use a recent kernel — Framework 13 benefits from fixes landed after 6.1.
    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "thunderbolt"
      "usb_storage"
      "sd_mod"
    ];
    # Early KMS for the boot splash on Iris Xe.
    boot.initrd.kernelModules = [ "i915" ];

    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

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

    # NVMe health.
    services.fstrim.enable = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
