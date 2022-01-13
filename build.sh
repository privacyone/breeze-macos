#!/bin/bash -eux

# Simple build script for macOS
set -e 
_root_dir=$(dirname $(greadlink -f $0))
_download_cache="$_root_dir/build/download_cache"
_src_dir="$_root_dir/build/src"
_main_repo="$_root_dir/core"
_breeze_patches="$_main_repo/patches/core/breeze"
_chromium_version=$(cat $_root_dir/core/chromium_version.txt)
_out_name="x86_64"

ARM_BUILD=false
BREEZE_SIGNING=false

mkdir -p "$_root_dir/out"

#arguments
while [ $# != 0 ]; do
    case $1 in
        --arm-build)
            _out_name="arm64"
            ARM_BUILD=true
            ;;
        --enable-signing)
            ENABLE_SIGNING=true
            ;;
        *)
            echo "ERROR: unknown parameter \"$1\""
            exit 1
            ;;
    esac
    shift
done

mkdir -p "$_src_dir/out/$_out_name"

#prepare build flags
cp "$_main_repo/flags.gn" "$_src_dir/out/$_out_name/args.gn"
cat "$_root_dir/flags.macos.gn" >> "$_src_dir/out/$_out_name/args.gn"
if [ "$ARM_BUILD" = true ]
then
    echo $'target_cpu="arm64"' | tee -a "$_src_dir/out/$_out_name/args.gn"
fi
if [ "$ENABLE_SIGNING" = true ]
then
    echo $'breeze_signing=true' | tee -a "$_src_dir/out/$_out_name/args.gn"
fi

#remove app if exists
rm -rf "$_src_dir/out/$_out_name/Breeze.app" || true

#copy all wip_src files
cp -a "$_main_repo/wip_src/src" "$_root_dir/build"
cp -a "$_main_repo/icons_src/src" "$_root_dir/build"

#copy all extensions crxs
cp -a "$_main_repo/supporting-extensions/default_extensions" "$_src_dir/chrome/browser/extensions"
cp -a "$_main_repo/breeze-dashboard/out/." "$_src_dir/chrome/browser/extensions/default_extensions"

cp -a "$_main_repo/privacy-master-controller" "$_src_dir/chrome/browser/resources/privacy_master_controller"
cp -a "$_main_repo/breeze-webstore-extension" "$_src_dir/chrome/browser/resources/breeze_webstore"

#run gn
cd "$_src_dir"

./tools/gn/bootstrap/bootstrap.py -o out/$_out_name/gn --skip-generate-buildfiles
./out/$_out_name/gn gen out/$_out_name --fail-on-unused-args

#start the build
if [ "$ENABLE_SIGNING" = true ]
then
    ninja -k 10 -C out/$_out_name chrome chromedriver chrome/installer/mac || { echo 'build failed' ; exit 0; }
    python "$_src_dir//out/$_out_name/Breeze Packaging/sign_chrome.py" \
    --identity D3D032D1F77838E42BFD41F732D08EBAC71A9FA3 \
    --input out/$_out_name \
    --output "$_root_dir/out/$_out_name" \
    # --notarize \
    # --notary-user @USERNAME \
    # --notary-password @PASSWORD 
else
    ninja -k 10 -C out/$_out_name chrome chromedriver || { echo 'build failed' ; exit 0; }
    xattr -csr out/$_out_name/Breeze.app
    # Using ad-hoc signing
    codesign --verbose --deep --sign - out/$_out_name/Breeze.app
    chrome/installer/mac/pkg-dmg \
    --sourcefile --source out/$_out_name/Breeze.app \
    --target "$_root_dir/out/$_out_name/Breeze.dmg" \
    --volname Breeze --symlink /Applications:/Applications \
    --format UDBZ --verbosity 2
fi
