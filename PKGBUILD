# Maintainer: Quentin Bouvet <qbouvet at outlook dot com>
pkgname="breath-of-the-wild-cemu"
pkgver=208
pkgrel=3
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
    "file://controller-config-xbox1.txt"
    "manual://Breath of the Wild (ALZP0101).zip"
    "manual://Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked).zip"
    "manual://Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked).zip"
    "https://github.com/ActualMandM/cemu_graphic_packs/releases/download/Github876/graphicPacks876.zip"
)
md5sums=(
    "SKIP"
    "SKIP"
    "SKIP"
    "SKIP"
    "SKIP" #?
    "SKIP" #47bbbefc8c68b6230de60ff84a90b26e
    "SKIP" #53e72865048b98404c96dfcba6179962
    "SKIP" #21f45373dec93707d6d6ca3b4bdd86fe
)
noextract=(
    "Breath of the Wild (ALZP0101).zip"
    "Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked).zip"
    "Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked).zip"
    "graphicPacks876.zip"
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
    TITLESTRING="00050000/101C9500" # Path inside cemu/mlc01/usr/title for updates / dlc path 
    RPXHASH="dcac9927"              # For transferrable shaders path

    cd "${srcdir}"    

    # Need separate directories for the base game, update files, dlc files, graphic packs
    mkdir -p "${pkgdir}/usr/share/${pkgname}/basegame"
    mkdir -p "${pkgdir}/usr/share/${pkgname}/mlc01/usr/title/$TITLESTRING/"
    mkdir -p "${pkgdir}/usr/share/${pkgname}/mlc01/usr/title/$TITLESTRING/aoc"
    mkdir -p "${pkgdir}/usr/share/${pkgname}/graphicPacks"
    mkdir -p "${pkgdir}/usr/share/${pkgname}/controllerProfiles"

    # Extract base game
    7z x -ao'a' \
      -o"${pkgdir}/usr/share/${pkgname}" \
      'Breath of the Wild (ALZP0101).zip'
    mv \
      "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (ALZP0101)'/* \
      "${pkgdir}/usr/share/${pkgname}/basegame/"

    # Extract Updates
    7z x -ao'a' \
      -o"${pkgdir}/usr/share/${pkgname}" \
      'Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked).zip'
    mv \
      "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked)'/* \
      "${pkgdir}/usr/share/${pkgname}/mlc01/usr/title/$TITLESTRING/"

    # Extract DLC
    7z x -ao'a' \
      -o"${pkgdir}/usr/share/${pkgname}" \
      'Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked).zip'
    mv \
      "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked)'/* \
      "${pkgdir}/usr/share/${pkgname}/mlc01/usr/title/$TITLESTRING/aoc"

    # Extract graphic packs
    7z x -ao'a' \
      -o"${pkgdir}/usr/share/${pkgname}/graphicPacks" \
      'graphicPacks876.zip'

    # Controller profile
    cp \
      controller-config-xbox1.txt \
      "${pkgdir}/usr/share/${pkgname}/controllerProfiles/xbox1.txt"
    ln -s \
      "${pkgdir}/usr/share/${pkgname}/controllerProfiles/xbox1.txt" \
      "${pkgdir}/usr/share/${pkgname}/controllerProfiles/controller0.txt"

    # Cleanup now-empty directories
    rmdir "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (ALZP0101)'
    rmdir "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked)'
    rmdir "${pkgdir}/usr/share/${pkgname}"/'Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked)'
    
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

