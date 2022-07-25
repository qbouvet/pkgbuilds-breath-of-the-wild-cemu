# Maintainer: Quentin Bouvet <qbouvet at outlook dot com>
pkgname="breath-of-the-wild-cemu"
pkgver=208
pkgrel=1
pkgdesc="Wii U game"
arch=('x86_64')
license=('none')
url=""

depends=('wine' 'winetricks' 'unionfs-fuse' 'cemu')
makedepends=('p7zip') # 'rar2fs', 'fuse3-p7zip-git' 'innoextract' 'libguestfs'

source=(
    "file://${pkgname}"
    "file://${pkgname}.png"
    "file://${pkgname}.desktop"
    "manual://Breath of the Wild (ALZP0101).zip"
    "manual://Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked).zip"
    "manual://Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked).zip"
    # + graphics pack
)
md5sums=(
    "SKIP"
    "SKIP"
    "SKIP"
    "SKIP"
    "SKIP" #47bbbefc8c68b6230de60ff84a90b26e
    "SKIP" #53e72865048b98404c96dfcba6179962
)
noextract=(
    "Breath of the Wild (ALZP0101).zip"
    "Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked).zip"
    "Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked).zip"
)
install="${pkgname}.install"


function notice() {
cat << EOF

PLEASE NOTE: 
    - You must manually provide the following files: 
        - 'Breath of the Wild (ALZP0101).zip'
        - 'Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked).zip'
        - 'Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked).zip'
    - These files can be obtained with 'WiiU USB Download Helper'
    - You should own a copy of the game

EOF
sleep 5
}


#   Typically, apply patches
#function prepare() {
#}


#   Typically, compile code
#function build() {
#}


#   Typically, run tests
#function check() {
#}


function package() {

    # 
    #   Magic constants
    #
    TITLESTRING="00050000_101C9500"
    RPXHASH="dcac9927"

    cd "${srcdir}"    

    # Need separate directories for the base game, update files, and dlc files
    # The install files eventually need to be mounted inside the CEMU installation files (?)
    mkdir -p "${pkgdir}/usr/share/${pkgname}/basegame"
    mkdir -p "${pkgdir}/usr/share/${pkgname}/mlc01/usr/title/$TITLESTRING/"
    mkdir -p "${pkgdir}/usr/share/${pkgname}/mlc01/usr/title/$TITLESTRING/aoc"


    # Extract base game
    7z x \
      -o"${pkgdir}/usr/share/${pkgname}" \
      -ao'a' \
      'Breath of the Wild (ALZP0101).zip'
    mv \
      "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (ALZP0101)'/* \
      "${pkgdir}/usr/share/${pkgname}/basegame/"
    # ^ This does not need to exist anywhere specific eventually

    # Extract Updates
    7z x \
      -o"${pkgdir}/usr/share/${pkgname}" \
      -ao'a' \
      'Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked).zip'
    mv \
      "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked)'/* \
      "${pkgdir}/usr/share/${pkgname}/mlc01/usr/title/$TITLESTRING/"

    # Extract DLC
    7z x \
      -o"${pkgdir}/usr/share/${pkgname}" \
      -ao'a' \
      'Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked).zip'
    mv \
      "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked)'/* \
      "${pkgdir}/usr/share/${pkgname}/mlc01/usr/title/$TITLESTRING/aoc"

    # Cleanup now-empty directories
    rmdir "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (ALZP0101)'
    rmdir "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked)'
    rmdir "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked)'

    # Still missing: graphics packs
    
    #   Set permissions
    find "$pkgdir"/usr/share -type f -exec chmod 644 "{}" \;
    find "$pkgdir"/usr/share -type d -exec chmod 755 "{}" \;
    
    #   Install binary wrapper / Icon / Desktop files
    install -m755 -D -t "${pkgdir}/usr/bin"                 "${pkgname}"
    install -D -t       "${pkgdir}/usr/share/icons/"        "${pkgname}.png"
    install -D -t       "${pkgdir}/usr/share/applications/" "${pkgname}.desktop"
}

#
# makepkg --printsrcinfo > .SRCINFO
#

