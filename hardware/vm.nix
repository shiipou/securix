# SPDX-FileCopyrightText: 2026 Sécurix project authors
#
# SPDX-License-Identifier: MIT

# QEMU/KVM virtual machine (virtio devices, no physical hardware).
# Use this SKU to test a Securix configuration in a VM before deploying
# it to real hardware.
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  config = lib.mkIf (config.securix.self.machine.hardwareSKU == "vm") {
    boot.initrd.availableKernelModules = [
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
      "9p"
      "9pnet_virtio"
    ];
    boot.initrd.kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];
    boot.extraModulePackages = [ ];

    # QEMU guest agent: clean shutdown, file system freeze for snapshots, etc.
    services.qemuGuest.enable = true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  };
}
