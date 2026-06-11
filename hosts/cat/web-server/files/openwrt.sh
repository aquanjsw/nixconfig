#/bin/sh

curl -L -o /etc/apk/keys/passwall.pub https://sourceforge.net/projects/openwrt-passwall-build/files/apk.pub

. /etc/os-release
main_minor_ver=${VERSION_ID%.*}
cat > /etc/apk/repositories.d/customfeeds.list <<EOF
https://phoenixnap.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-${main_minor_ver}/${OPENWRT_ARCH}/passwall_packages/packages.adb
EOF
