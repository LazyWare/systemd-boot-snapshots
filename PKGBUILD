# File: PKGBUILD
# Project Path: ./PKGBUILD
# Installation Path: N/A (used only for building the package)
#
# Maintainer: [Anonimo] <anonimo@vivaldi.net>
pkgname=systemd-boot-snapshots
pkgver=0.1.0
pkgrel=1
pkgdesc="Enhances systemd-boot by adding BTRFS snapshots to the boot menu"
arch=('any')
url="https://github.com/LazyWare/systemd-boot-snapshots"
license=('GPL3')
depends=('systemd' 'btrfs-progs')
optdepends=('timeshift: support for Timeshift snapshots'
            'snapper: support for Snapper snapshots'
            'libnotify: support for desktop notifications'
            'mkinitcpio: standard Arch Linux initramfs generator'
            'dracut: alternative initramfs generator')
backup=('etc/default/systemd-boot-snapshots.conf')
install=${pkgname}.install
source=("${pkgname}-${pkgver}.tar.gz::${url}/archive/v${pkgver}.tar.gz")
sha256sums=('48b0f6c0cb147d41c685ab684949861971b92ff2496ae87dcd49882078527216')

package() {
  cd "${srcdir}/${pkgname}-${pkgver}"
  
  # Create directories
  install -dm755 "${pkgdir}/etc/default"
  install -dm755 "${pkgdir}/usr/bin"
  install -dm755 "${pkgdir}/usr/lib/systemd-boot-snapshots"
  install -dm755 "${pkgdir}/usr/lib/initcpio/hooks"
  install -dm755 "${pkgdir}/usr/lib/initcpio/install"
  install -dm755 "${pkgdir}/usr/lib/systemd/system"
  install -dm755 "${pkgdir}/usr/lib/dracut/modules.d/90systemd-boot-snapshots"
  
  # Install configuration
  install -Dm644 systemd-boot-snapshots.conf "${pkgdir}/etc/default/systemd-boot-snapshots.conf"
  
  # Install main scripts
  install -Dm755 update-systemd-boot-snapshots "${pkgdir}/usr/bin/update-systemd-boot-snapshots"
  install -Dm755 systemd-boot-mount-snapshot-modules "${pkgdir}/usr/lib/systemd-boot-snapshots/systemd-boot-mount-snapshot-modules"
  install -Dm755 systemd-boot-snapshots-notify "${pkgdir}/usr/lib/systemd-boot-snapshots/systemd-boot-snapshots-notify"
  
  # Install mkinitcpio hooks
  install -Dm644 mkinitcpio/hooks/systemd-boot-snapshots "${pkgdir}/usr/lib/initcpio/hooks/systemd-boot-snapshots"
  install -Dm644 mkinitcpio/install/systemd-boot-snapshots "${pkgdir}/usr/lib/initcpio/install/systemd-boot-snapshots"
  
  # Install dracut module
  install -Dm755 dracut/90systemd-boot-snapshots/module-setup.sh "${pkgdir}/usr/lib/dracut/modules.d/90systemd-boot-snapshots/module-setup.sh"
  install -Dm755 dracut/90systemd-boot-snapshots/systemd-boot-snapshots.sh "${pkgdir}/usr/lib/dracut/modules.d/90systemd-boot-snapshots/systemd-boot-snapshots.sh"
  ln -sf /usr/lib/systemd-boot-snapshots/systemd-boot-mount-snapshot-modules "${pkgdir}/usr/lib/dracut/modules.d/90systemd-boot-snapshots/systemd-boot-mount-snapshot-modules.sh"
  ln -sf /usr/lib/systemd-boot-snapshots/systemd-boot-snapshots-notify "${pkgdir}/usr/lib/dracut/modules.d/90systemd-boot-snapshots/systemd-boot-snapshots-notify"
  
  # Install systemd units
  install -Dm644 update-systemd-boot-snapshots.service "${pkgdir}/usr/lib/systemd/system/update-systemd-boot-snapshots.service"
  install -Dm644 systemd-boot-entries.path "${pkgdir}/usr/lib/systemd/system/systemd-boot-entries.path"
  install -Dm644 snapper-snapshots.path "${pkgdir}/usr/lib/systemd/system/snapper-snapshots.path"
  install -Dm644 timeshift-snapshots.path "${pkgdir}/usr/lib/systemd/system/timeshift-snapshots.path"
  
  # Install documentation
  install -Dm644 README.md "${pkgdir}/usr/share/doc/${pkgname}/README.md"
  install -Dm644 CHANGELOG.md "${pkgdir}/usr/share/doc/${pkgname}/CHANGELOG.md"
  install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
