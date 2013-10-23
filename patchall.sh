#!/bin/bash
cd `dirname $0`
DSTDIR=$1

if [ -z "$DSTDIR" ]
then
    echo "Usage: $0 <sources dir>"
    exit 1
fi

red=$(tput setaf 1) # Red
grn=$(tput setaf 2) # Green
txtrst=$(tput sgr0) # Reset

# back port bluez
echo ""
echo "${grn}Back porting bluez${txtrst}"

DISTR=`head -1 $DSTDIR/.repo/manifests/README.*`

case "$DISTR" in
  "CyanogenMod")
    echo "${grn}---=== CyanogenMod ===---${txtrst}"
    bluez_port_cm101/cm101_bluez_patch.sh $DSTDIR

    # Vibe patch
    echo ""
    echo "${grn}Applying Vibe patch${txtrst}"
    cat allpatches/PhoneWindowManager.patch | patch -d $DSTDIR/frameworks/base -p1 -N -r -

    # Show Network Speed patch
    echo ""
    echo "${grn}Applying Show Network Speed patch (by realmenvvs 4pda)${txtrst}"
    cp  allpatches/traffic/Traffic.java $DSTDIR/frameworks/base/packages/SystemUI/src/com/android/systemui/statusbar/policy
    cat allpatches/traffic/traffic.patch | patch -d $DSTDIR -p1 -N -r -

    echo ""
    echo "${grn}transparency of the bottom field (by holl 4pda)${txtrst}"
    cat allpatches/PhoneTransparencyButtom.patch | patch -d $DSTDIR/packages/apps/Phone -p1 -N -r -

    ;;
  "MoKee OpenSource")
    echo "${grn}---=== MoKee OpenSource ===---${txtrst}"
    bluez_port_cm101/cm101_bluez_patch.sh $DSTDIR
    ;;
  "PAC-man - The AIO ROM")
    echo "${grn}---=== PAC-man - The AIO ROM ===---${txtrst}"
    bluez_port_pac/pac_bluez_patch.sh $DSTDIR
    cp -f allpatches/cm_frameworks_config_overlay.xml $DSTDIR/vendor/cm/overlay/common/frameworks/base/core/res/res/values/config.xml

    # Vibe patch
    echo ""
    echo "${grn}Applying Vibe patch${txtrst}"
    cat allpatches/PhoneWindowManager_pac.patch | patch -d $DSTDIR/frameworks/base -p1 -N -r -

    ;;
  *)
    echo "${red}*================== Error!!! ================*"
    echo "| Who is here? I do not know what the system |"
    echo "*============================================*${txtrst}"
    exit 1
  ;;
esac

# AudioRecord patch
echo ""
echo "${grn}Applying AudioRecord patch${txtrst}"
cat allpatches/AudioRecord.patch | patch -d $DSTDIR/frameworks/av/ -p1 -N -r -

# Adding caller geo info database
echo ""
echo "${grn}Adding CallerGeoInfo data${txtrst}"
cp allpatches/geoloc/86_zh $DSTDIR/external/libphonenumber/java/src/com/android/i18n/phonenumbers/geocoding/data/86_zh
cp allpatches/geoloc/PhoneNumberMetadataProto_CN $DSTDIR/external/libphonenumber/java/src/com/android/i18n/phonenumbers/data/PhoneNumberMetadataProto_CN

# EMUI Gallery/Camera patch
echo ""
echo "${grn}Applying EMUI Gallery/Camera patch${txtrst}"
cat allpatches/EMUI_Gallery2.patch | patch -d $DSTDIR/frameworks/base -p1 -N -r -

# Camera patch
echo ""
echo "${grn}Applying Camera patch${txtrst}"
cat allpatches/Camera.patch | patch -d $DSTDIR/packages/apps/Camera -p1 -N -r -

# SurfaceFlinger patch
echo ""
echo "${grn}Applying SurfaceFlinger patch${txtrst}"
cat allpatches/SurfaceFlinger.patch | patch -d $DSTDIR/frameworks/native -p1 -N -r -

# WiFi Country patch
echo ""
echo "${grn}Applying WiFi Country patch${txtrst}"
cat allpatches/WiFi_Country.patch | patch -d $DSTDIR/frameworks/opt/telephony -p1 -N -r -

# if not removed - there will be errors
echo ""
echo "${grn}Remove *.orig files${txtrst}"
rm -f $DSTDIR/frameworks/base/core/res/res/values/*.orig

echo "${grn}Done${txtrst}"
