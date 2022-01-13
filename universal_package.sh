#!/bin/bash -eux

# Simple build script for macOS
set -e 
_root_dir=$(dirname $(greadlink -f $0))
_download_cache="$_root_dir/build/download_cache"
_src_dir="$_root_dir/build/src"
_main_repo="$_root_dir/core"
_breeze_patches="$_main_repo/patches/core/breeze"
_chromium_version=$(cat $_root_dir/core/chromium_version.txt)

cd "$_src_dir"

mkdir -p out/release_universal
rm -rf "$_src_dir/out/release_universal/Breeze.app" || true
cp -a "$_src_dir/out/x86_64/Breeze Packaging" "$_src_dir/out/release_universal/Breeze Packaging"

#merge
chrome/installer/mac/universalizer.py \
    out/x86_64/Breeze.app \
    out/arm64/Breeze.app \
    out/release_universal/Breeze.app

#package and sign
python "$_src_dir/out/release_universal/Breeze Packaging/sign_chrome.py" \
--identity D3D032D1F77838E42BFD41F732D08EBAC71A9FA3 \
--input out/release_universal \
--output "$_root_dir/out/release_universal" \
# --notarize \
# --notary-user @USERNAME \
# --notary-password @PASSWORD 
