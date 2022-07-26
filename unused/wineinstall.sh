#!/usr/bin/env bash
read -r -d '' usage_str << EOF
.
    CEMU wine installer
    
    Change the language, don't change the default paths in the installer

    Parametrizable wine game installation script. Functions : 
        - Parse wineprefix path from CLI 
        - Create / setup wineprefix 
        - Install wine libs using bundled winetricks and winetricks cache
        - Install game <-- CODE FOR THIS PART MUST BE ADAPTED ON A PER-GAME BASIS
        - create .desktop files
    
    Args : 
        --PREFIX    specify \$WINEPREFIX path
        --DESKTOP   create desktop shortcut
        --USER      create app shortcut for user
        --ALLUSERS  create app shortcut for all users (requires sudo)
        --VERSION   version string, passed to installer()

    Usage : $0 --PREFIX <prefix path> --DESKTOP

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
params["PREFIX"]="/home/quentin/DATA_700/WINE_LIB/WINE_CEMU_1154"
params["DESKTOP"]="true"
params["USER"]="false"
params["ALLUSERS"]="true"
params["VERSION"]="1.15.4"


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
pprint_assoc_array params "\nCLI parameters : ";
echo "Go ?"; read;


########################################################################
######################      VARIABLES      #############################
########################################################################

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

WINEPREFIX=${params[PREFIX]}
WINEARCH="win64"    # win32, win64
WINVER="win10"      # winxp, win10

WINEDLLS="dbghelp=n,b;"

WINELIBS="vcrun2015 corefonts"
WINETRICKSCACHE="winetrickscache"
WINECACHE="winecache"

DF_NAME="Cemu ${params[VERSION]}"
DF_ICON="CEMU2.png"
DF_PATH="drive_c/cemu_${params[VERSION]}"
DF_EXEC="Cemu.exe"
DF_VARS="__GL_THREADED_OPTIMIZATIONS=1 WINEDEBUG=-all,+fps "

DF_ALL_USERS=${params[ALLUSERS]}
DF_CUR_USER=${params[USER]}
DF_DESKTOP=${params[DESKTOP]}


########################################################################
####################      INSTALLERS PART      #########################
########################################################################

    #
    #   Automated cemu installer, just pass version string as parameter
    #
function install () {

printf "\n$ install ${params[VERSION]}\n";

VER="$1";

CODE="$(echo $VER | sed 's|\.||g')";
CEMUARCHIVE="$(ls | grep cemu_*.zip)";
CEMUHOOK="$(ls | grep cemuhook_*.zip)";
CEMUHOOK_FONTS="$(ls | grep cemuhook-fonts*)";
INSTALLDIR="$WINEPREFIX/drive_c";
CEMUDIR="$INSTALLDIR/cemu_$VER";

printf "\n\n Parsed in directory :\n";
echo "Cemu archive   : $CEMUARCHIVE";
echo "Cemuhook file  : $CEMUHOOK";
echo "Cemuhook fonts : $CEMUHOOK_FONTS";
echo "Install dir    : $INSTALLDIR";
echo "Cemu dir       : $CEMUDIR";
echo "Go ? "; read;

# extract install files
unzip "$CEMUARCHIVE" -d "$INSTALLDIR" ;

# Add WII U game to cemu/keys.txt  (not sure what it does)
commonkeys="
## Wii U common keys from TPB
##
D7B00402659BA2ABD2CB0DB27FA2B656 # Wii U Common Key
36262B5F49C69164E3BE2BB87C9922A7 # Wii U Common Key
A851D78AB8F0A6FE1E93CFCEAF99A179 # Wii U Common Key 
D7B00402659BA2ABD2CB0DB27FA2B656 # Wii U Common Key
36262B5F49C69164E3BE2BB87C9922A7 # Wii U Common Key
A851D78AB8F0A6FE1E93CFCEAF99A179 # Wii U Common Key"
echo "$commonkeys" >> $CEMUDIR/keys.txt

# extract cemuhook
unzip -o "$CEMUHOOK" -d "$CEMUDIR"
cp -r "$CEMUHOOK_FONTS" "$CEMUDIR/sharedFonts";
#printf "\n\n\n# libraries > dbghelp.dll=native,builtin\n\n"
#winecfg    # libraries > dbghelp.dll=native,builtin

# controller setup
mkdir -p  $CEMUDIR/controllerProfiles/
cp controller-xbox1.txt $CEMUDIR/controllerProfiles/xbox1.txt
cp controller-xbox1.txt $CEMUDIR/controllerProfiles/controller0.txt

# CEMU options 
settingsstr="
Settings (CEMU 1.15.4, BOTW V208) : 

Options >   GX2SetGPUFenceSkip = yes
        >   GPUBufferCacheAccuracy = low
        >   Experimental        >   Use RDTSC = No  (Crucial)
        >   General settings    
                > Graphics      >   Full synt at GXDrawDone = yes
                                >   Use separable shader    = yes
                                >   Upscale filter          = bilinear    
                                >   Downscale filter        = bicubic
                                >   Overlay Position        = top right
                > Audio     >

CPU     >   Mode     = triple core recompiler
        >   Timer    = Host based timer
        >   Affinity = Custom (-> odd cores)

Debug   >   Custom timer        = QPC (crucial)
        >   MM Timer accuracy   = 1 ms
"
printf "\n\n\n$settingsstr"
printf "\n\n [Please take a moment to setup cemu]\n\n"
sleep 1.5s;
pushd "$CEMUDIR"
WINEARCH="$WINEARCH" WINEPREFIX="$WINEPREFIX" WINEDLLOVERRIDES="$WINEDLLS" wine Cemu.exe;
popd;

}


########################################################################
##################      STANDARD WINE PART      ########################
########################################################################


# Export necessary variables 
export WINEPREFIX="$WINEPREFIX";
export WINEARCH="$WINEARCH";


# Export winetricks cache 
printf "\n\n [Copying wine & winetricks caches]\n\n"
if [ "$WINECACHE" != "" ] ; then
    cp -a "$__dir"/"$WINECACHE"/* ~/.cache/wine;
fi 
if [ "$WINETRICKSCACHE" != "" ] ; then
    cp -a "$__dir"/"$WINETRICKSCACHE"/* ~/.cache/winetricks;
fi


# Create wineprefix
printf "\n\n [Creating wineprefix]\n\n"
if ! [ -d "$WINEPREFIX" ] ; then 
    mkdir -p "$WINEPREFIX";
    pushd "$WINEPREFIX";
    wineboot;
fi 


# Configure wineprefix 
printf "\n\n [Configuring wineprefix]\n\n"
"$__dir"/winetricks-exe "$WINVER";
if [ "$WINELIBS" != "" ]; then
    "$__dir"/winetricks-exe $WINELIBS;
fi


# call installer
popd;
printf "\n\n [Running installer]\n\n";
install "${params[VERSION]}";


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
Exec=env ${DF_VARS} WINEARCH=${WINEARCH} WINEPREFIX=${WINEPREFIX} WINEDLLOVERRIDES=${WINEDLLS} wine ${DF_EXEC}
Terminal=false
Type=Application
StartupNotify=true
Keywords=Games;"

if [ "$DF_DESKTOP" == "true" ] ; then
    echo "$desktopfile" > ~/Desktop/"$DF_NAME".desktop
fi
if [ "$DF_CUR_USER" == "true" ] ; then 
    echo "$desktopfile" > ~/.local/share/applications/"$DF_NAME".desktop
fi
if [ "$DF_ALL_USERS" == "true" ] ; then 
    cmd="echo '$desktopfile' > /usr/share/applications/${DF_NAME}.desktop"
    sudo bash -c "$cmd"
fi





