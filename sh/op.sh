#!/bin/bash

function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../
  cd .. && rm -rf $repodir
}

echo 'src-git dns https://github.com/sbwml/luci-app-mosdns' >>feeds.conf.default
echo 'src-git xd https://github.com/shiyu1314/openwrt-packages' >>feeds.conf.default

git clone -b master --depth 1 --single-branch https://github.com/vernesong/OpenClash package/xd/luci-app-openclash

git clone -b master --depth 1 --single-branch https://github.com/jerrykuku/luci-theme-argon package/xd/luci-theme-argon

git_sparse_clone master https://github.com/immortalwrt/immortalwrt package/emortal
git_sparse_clone master https://github.com/immortalwrt/immortalwrt package/utils/mhz
git_sparse_clone master https://github.com/immortalwrt/immortalwrt package/network/services/dnsmasq 
git_sparse_clone master https://github.com/immortalwrt/luci modules/luci-base
git_sparse_clone master https://github.com/immortalwrt/luci modules/luci-mod-status

./scripts/feeds update -a
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/modules/luci-base
rm -rf feeds/luci/modules/luci-mod-status
rm -rf package/network/services/dnsmasq
cp -rf emortal package
cp -rf mhz package/utils/
cp -rf luci-base feeds/luci/modules
cp -rf luci-mod-status feeds/luci/modules/
cp -rf dnsmasq package/network/services/

./scripts/feeds update -a
./scripts/feeds install -a

sed -i "s/192.168.1.1/10.0.0.254/" package/base-files/files/bin/config_generate
sed -i 's/OpenWrt/BitWrt/g' package/base-files/files/bin/config_generate
sed -i 's/default \"OpenWrt\"/default \"BitWrt\"/g' package/base-files/image-config.in
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config


sudo rm -rf package/base-files/files/etc/banner
sudo cp -f $GITHUB_WORKSPACE/sh/99-default-settings package/emortal/default-settings/files/99-default-settings

echo "old:"
cat $GITHUB_WORKSPACE/sh/99-default-settings
echo "new:"
cat package/emortal/default-settings/files/99-default-settings

date=$(date +"%Y-%m-%d")
echo "                                                    " >> package/base-files/files/etc/banner
echo "         ____  _ _ __        __    _   " >> package/base-files/files/etc/banner
echo "        | __ )(_) |\ \      / / __| |_ " >> package/base-files/files/etc/banner
echo "        |  _ \| | __\ \ /\ / / '__| __|" >> package/base-files/files/etc/banner
echo "        | |_) | | |_ \ V  V /| |  | |_ " >> package/base-files/files/etc/banner
echo "        |____/|_|\__| \_/\_/ |_|   \__|" >> package/base-files/files/etc/banner
echo " -----------------------------------------------------" >> package/base-files/files/etc/banner
echo "         %D ${date} by bitbears                     " >> package/base-files/files/etc/banner
echo " -----------------------------------------------------" >> package/base-files/files/etc/banner
