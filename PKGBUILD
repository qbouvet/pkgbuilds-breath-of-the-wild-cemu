# Maintainer: Quentin Bouvet <qbouvet at outlook dot com>
pkgname="breath-of-the-wild-cemu"
pkgver=0.0.1
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

    cd "${srcdir}"    
    mkdir -p "${pkgdir}/usr/share/${pkgname}"

    # Extract archives directly to $srcdir  
    #   -o: output directory
    #   -ao: overwrite mode (a=all)
    7z x \
      -o"${pkgdir}/usr/share/${pkgname}/" \
      -ao'a' \
      'Anomaly-1.5.1.7z'
    7z x \
      -o"${pkgdir}/usr/share/${pkgname}/" \
      -ao'a' \
      'Anomaly-1.5.1-to-1.5.2-Update.7z'
    
    #   Set permissions
    find "$pkgdir"/usr/share -type f -exec chmod 644 "{}" \;
    find "$pkgdir"/usr/share -type d -exec chmod 755 "{}" \;
    
    #   Install binary wrapper / Icon / Desktop files
    install -m755 -D -t "${pkgdir}/usr/bin" \
      "${pkgname}"
    install -D -t "${pkgdir}/usr/share/icons/" \
      "${pkgname}.png"
    install -D -t "${pkgdir}/usr/share/applications/" \
      "${pkgname}.desktop"
    install -D -t "${pkgdir}/usr/share/applications/" \
      "${pkgname}-launcher.desktop"
}

#
# makepkg --printsrcinfo > .SRCINFO
#

