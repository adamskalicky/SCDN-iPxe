DEVROOT=/home/corp.ads.scencdn.com/adam.skalicky/Desktop/pxe_build
#VERSION TRACKING#
BUILD_MAN="manifest.txt"
Dev_Logs="$DEVROOT/Dev_Logs"

touch $BUILD_MAN
read -p "Enter changes : " changesum
BUILD_ORIG=$(head -n 1 $BUILD_MAN)
if [ -z "$BUILD_ORIG" ]
then 
touch $BUILD_MAN
rm -f $BUILD_MAN
touch $BUILD_MAN
echo "New Build" | cat - $BUILD_MAN > temp && mv temp $BUILD_MAN
echo "0.00" | cat - $BUILD_MAN > temp && mv temp $BUILD_MAN
BUILD_ORIG=$(head -n 1 $BUILD_MAN)
fi

BUILD_VAR=$(echo $BUILD_ORIG | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}')
echo $BUILD_ORIG | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'

echo "Building $BUILD_VAR"
echo "Changes: $changesum" | cat - $BUILD_MAN > temp && mv temp $BUILD_MAN
echo 'Build Number Listed Above' | cat - $BUILD_MAN > temp && mv temp $BUILD_MAN
echo "$BUILD_VAR" | cat - $BUILD_MAN > temp && mv temp $BUILD_MAN

mkdir -p $Dev_Logs



#MAKE
rm -rf "$DEVROOT/scdn-master/script/ipxe_build/"
rm -rf "$DEVROOT/scdn-master/ipxe_build/"
cd "$DEVROOT/scdn-master/"
script/prep-release.sh --clean | tee "$Dev_Logs/iPXE_Build-$BUILD_VAR.txt"

#SYNC Site
rsync -avzp --delete "$DEVROOT/scdn-master/site/" root@websv01-kan1:/home/scencdn/web/pxe.scencdn.com/public_html/


#Sync Menu Files to PR Web Server
rsync -avzp --delete  "$DEVROOT/scdn-master/src/" root@websv01-kan1:/home/scencdn/web/boot.pxe.scencdn.com/public_html/


#Sync Source Code to Source Folder
#rsync -avzp --delete /home/corp.ads.scencdn.com/adam.skalicky/Desktop/scdn-master/ root@websv01-kan1:/home/scencdn/web/pxe.scencdn.com/public_html/source/



