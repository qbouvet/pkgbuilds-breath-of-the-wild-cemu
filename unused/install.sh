#!/usr/bin/env bash
read -r -d '' usage_str << EOF
.
    Breath of the Wild wine installer
    
    Does some data copying and a call to the underlying cemu's 
    wineinstall.sh
    
    All files 'info_*thing*_***' need to be set correctly denpending on 
    the region.
    
    Args : 
        --GAMESDIR      path to directory containing CEMU base games
        --INSTALLCEMU   false -> assume cemu already installed in PREFIX
        --PREFIX        specify \$WINEPREFIX path
        --DESKTOP       create desktop shortcut
        --USER          create app shortcut for user
        --ALLUSERS      create app shortcut for all users (requires sudo)
        --VERSION       version string, passed to installer()

    Usage : $0 --PREFIX <prefix path> --DESKTOP --version "1.15.4"

.
EOF

if [ $# -gt 0 ] && { [ "$1" == "-h" ] || [ "$1" == "--help" ] ;} ; then
    printf "$usage_str"
    exit 0
fi

## Debug flags & bash magic
set -o nounset      # exit on unassigned variable
set -o errexit      # exit on error
set -o pipefail     # exit on pipe fail
#set -o xtrace       # Display xtrace



########################################################################
###################      PARSING HELPERS       #########################
########################################################################
#               Hard-copy from /scripts/utils.sh                       #

    #
    #   CLI parameters
    #
declare -A params
params["PREFIX"]="/home/quentin/DATA_700/WINE_LIB/WINE_CEMU_1154_BOTW"
params["INSTALLCEMU"]="false"
params["GAMESDIR"]="/home/quentin/DATA_700/WINE_LIB/cemugames"
params["VERSION"]="1.15.4"
params["DESKTOP"]="true"
params["USER"]="false"
params["ALLUSERS"]="true"



function pprint_assoc_array {
    declare -n aarray="$1"
    keylen=20
    [ "$#" -ge 2 ] && printf "$2\n" 
    [ "$#" -lt 2 ] && printf "ASSOCIATIVE ARRAY\n"
    for key in "${!aarray[@]}"; do
        printf "  + %-${keylen}s	: %s \n" "$key" ${aarray["$key"]}
    done
    printf "END\n"
}

function hasKey {
    declare -n aarray="$1"
    if [ "${aarray[$2]+someDefaultString}" ] ; then
        echo "true"
    else 
        echo ""
    fi
}

function parse_params () {
    declare -n paramMap="$1"
    itr=2
    while [ $itr -le $# ]; do
        argname="${!itr}"; 
        # remove '--' and transform '-' -> '_'
        pname=$(echo $argname | sed 's/--//' | sed 's/-/_/');
        itr=$((itr+1)) 		# In any case, we'll skip to the next parameter
        echo "parsing parameter $pname"
        # Check parameter exists in 'params'
        if [ ! $(hasKey paramMap "$pname") ] ; then
            printf "\nError : Argument not recognized : $pname\n"
        # nothing afterwards -> necessarily boolean flag
        elif [ $itr -gt $# ]; then 
            if [ ${paramMap["$pname"]} != "true" ] && [ ${paramMap["$pname"]} != "false" ]  ; then
                printf "Parameter doesnt seem to be a boolean flag : $pname\n";
            else 
                paramMap[$pname]="true";
            fi
        # pname is a recognized parameter AND we've got something afterwards
        else
            nextarg="${!itr}"; 
            # If the next string is an option, then we have a boolean flag
            if [ "${nextarg:0:2}" == "--" ]; then
                if [ ${paramMap["$pname"]} != "true" ] && [ ${paramMap["$pname"]} != "false" ]  ; then
                    printf "Parameter doesnt seem to be a boolean flag : $pname\n\n";
                else 
                    paramMap[$pname]="true";
                fi
            # Otherwise, we have a valued parameter
            else 
                paramMap[$pname]="${!itr}";
                itr=$((itr+1));	    # skip value
            fi
        fi
    done
}

parse_params params ${@:1};



########################################################################
######################      VARIABLES      #############################
########################################################################

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WINEPREFIX=${params[PREFIX]}
WINEARCH="win64"    # win32, win64
WINEDLLS="dbghelp=n,b;"

GAMESDIR="${params[GAMESDIR]}"
GAMESDIR_WIN="Z:"$(echo "$GAMESDIR" | sed 's|/|\\|g')

DF_NAME="Breath of the Wild - CEMU ${params[VERSION]}"
DF_ICON="BOTW1.png"
DF_PATH="drive_c/cemu_${params[VERSION]}"
DF_VARS="__GL_THREADED_OPTIMIZATIONS=1 "
DF_EXEC="Cemu.exe -g \"$GAMESDIR_WIN\\The Legend of Zelda Breath of the Wild (ALZP0101)\\code\\U-King.rpx\""

DF_ALL_USERS=${params[ALLUSERS]}
DF_CUR_USER=${params[USER]}
DF_DESKTOP=${params[DESKTOP]}


########################################################################
#####################      CEMU INSTALLER      #########################
########################################################################

# cemu, using its own wineinstall.sh
CEMUARCHIVE="$(ls "$__dir" | grep WINE-CEMU-*.tgz)";
tmp="$(echo $CEMUARCHIVE | sed 's:.tgz::')";
if [ "${params[INSTALLCEMU]}" == "true" ] ; then
    printf "\n\n [Installing CEMU]\n\n";
    tar -xvzf "$CEMUARCHIVE";
    pushd "$tmp";
    ./wineinstall.sh --PREFIX "$WINEPREFIX" --VERSION "${params[VERSION]}" \
        --DESKTOP false --USER false --ALLUSERS true;
    popd;
fi 


########################################################################
#####################      BOTW INSTALLER      #########################
########################################################################

printf "\n\n [Installing BOTW]\n\n";

    #
    # Need to set many variables    
    #
    # Find files in directory
SHADERCACHE="$(ls "$__dir" | grep botw-shadercache-*.bin)";
GRAPHICSPACK="$(ls "$__dir" | grep graphicspack-botw-*)";
    # Parse info from file names
RPXHASH="$(ls "$__dir" | grep info_rpxhash_* | sed 's|info_rpxhash_||')";
TITLESTRING="$(ls "$__dir" | grep info_titlestring_* | sed 's:info_titlestring_::' | sed 's:_:/:')";
    # Construct paths accordingly
CEMUDIR="$WINEPREFIX/drive_c/cemu_${params[VERSION]}";
UPDATEDIR="${CEMUDIR}/mlc01/usr/title/$TITLESTRING";
DLCDIR="$UPDATEDIR/aoc";

pprint_assoc_array params "\nCLI parameters : ";
printf "\n\nDetected in current folder : \n";
echo "CEMUDIR      : $CEMUDIR";
echo "UPDATEDIR    : $UPDATEDIR";
echo "DLCDIR       : $DLCDIR";
echo "SHADERCACHE  : $SHADERCACHE";
echo "RPXHASH      : $RPXHASH";
echo "GRAPHICSPACK : $GRAPHICSPACK";
echo "Go ? "; read;


    #
    # Copy base game to GAMESDIR
    #
mkdir -p "$GAMESDIR"
name="The Legend of Zelda Breath of the Wild (ALZP0101)"
if ! [ -d "${GAMESDIR}/${name}" ] ; then 
    printf "\n\n [Copying base game]\n\n";
    cp -a "$name" "${WINEPREFIX}${GAMESDIR};"
else 
    printf "\n\n [Base game already exists, not copying]\n\n";    
fi

    #
    # Copy updates / DLC / graphicspack / shadercache to CEMUDIR
    #
printf "\n\n [Copying UPDATES/dlc/graphicspack/shadercache]\n\n";
mkdir -p "$UPDATEDIR";
cp -a "Breath of the Wild (UPDATE DATA) (v208) (3.253 GB) (EUR) (unpacked)"/* \
        "${UPDATEDIR}";
echo "(updates copied)"
mkdir -p "$DLCDIR";
cp -a "Breath of the Wild (DLC) (2.297 GB) (EUR) (unpacked)"/* \
        "${DLCDIR}";
echo "(DLCs copied)"
cp -a "$GRAPHICSPACK"/* "${CEMUDIR}/graphicPacks/"
cp -a "$SHADERCACHE" "$CEMUDIR"/shaderCache/transferable/"$RPXHASH".bin
sync

    #
    # Some config files
    #
# BOTW/common keys - Not sure what they do
keys=" \
D7B00402659BA2ABD2CB0DB27FA2B656 # Zelda BOTW
36262B5F49C69164E3BE2BB87C9922A7 # Zelda BOTW
A851D78AB8F0A6FE1E93CFCEAF99A179 # Zelda BOTW
D7B00402659BA2ABD2CB0DB27FA2B656 # Zelda BOTW
36262B5F49C69164E3BE2BB87C9922A7 # Zelda BOTW
A851D78AB8F0A6FE1E93CFCEAF99A179 # Zelda BOTW"
printf "\n\n$keys" >> $CEMUDIR/keys.txt
#   BOTW config file 
#   !!! This doesn do much at all, may even worsen a  bit !!!
#   -> Do your own tests
botwconfig="# TLoZ: Breath of the Wild (EUR)
\n[General]
useRDTSC= true
\n[CPU] 
cpuMode = TripleCore-Recompiler
\n[Graphics]
extendedTextureReadback = true
disableGPUFence = false  
    # Optional
    # true -> standard behaviour
    # min -> reduces RAM usage, artifacts, require deletion of shadercache/precompiled
accurateShaderMul = min
GPUBufferCacheAccuracy = 2\n"
tmp="$(echo $TITLESTRING | sed 's:/::')"
printf "$botwconfig" > "${CEMUDIR}/gameProfiles/${tmp}.ini"


########################################################################
####################        DESKTOP FILES      #########################
########################################################################

# Make .desktop file
printf "\n\n [Creating .desktop files]\n\n"
xdg-icon-resource install --size 64 --novendor --context mimetypes "$DF_ICON"
xdg-icon-resource install --size 32 --novendor --context mimetypes "$DF_ICON"
desktopfile=" \
#!/usr/bin/env xdg-open
[Desktop Entry]
Name=${DF_NAME}
Icon=${DF_ICON}
Path=${WINEPREFIX}/${DF_PATH}
Exec=bash -c 'env ${DF_VARS} WINEARCH=${WINEARCH} WINEPREFIX=${WINEPREFIX} WINEDLLOVERRIDES=${WINEDLLS} \
wine ${DF_EXEC}'
Terminal=false
Type=Application
StartupNotify=true
Keywords=Games;"

echo "$desktopfile" > "${DF_NAME}.desktop"
[ "$DF_DESKTOP" == "true" ] && cp "${DF_NAME}.desktop" ~/Desktop/
[ "$DF_CUR_USER" == "true" ] && cp "${DF_NAME}.desktop" ~/.local/share/applications/
[ "$DF_ALL_USERS" == "true" ] && sudo cp "${DF_NAME}.desktop" /usr/share/applications/


printf "\n\n [Done !]\n\n"

printf "\n Please take a moment to configure the graphics packs.

    For performance
    ===============
    
MODS
    FPS++
        dynamic gamespeed   = true
        fence method        = performance fence
        set FPS limit       = 120Hz
        NPC stutter fix     = true
WORKAROUNDS
    kakariko torch shadows  = true
    LWVZX crash             = true
    nvidia explosion smoke  = true
GRAPHICS
    Anti-aliasing
        disabled
    resolution
        1080p
ENHANCEMENT
    No depth of field   = true
    
    
    For much wow
    =============
    
- clarity
- reflExtra
\n"




