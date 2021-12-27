#!/bin/bash -eux

# Simple build script for macOS
set -e 
_root_dir=$(dirname $(greadlink -f $0))
_download_cache="$_root_dir/build/download_cache" 
_src_dir="$_root_dir/build/src"
_temp_patches="$_root_dir/build/temp_patches"
_saved_patches="$_root_dir/build/saved_patches"
_main_repo="$_root_dir/core"
_breeze_patches="$_main_repo/patches/core/breeze"

# For packaging
_chromium_version=$(cat $_root_dir/core/chromium_version.txt)
if [[ ! -d build/src/chrome ]]
then
    mkdir -p "$_src_dir/out/Default"
    mkdir -p "$_download_cache"

    "$_main_repo/utils/downloads.py" retrieve -i "$_main_repo/downloads.ini" "$_root_dir/downloads.ini" -c "$_download_cache"
    "$_main_repo/utils/downloads.py" unpack -i "$_main_repo/downloads.ini" "$_root_dir/downloads.ini" -c "$_download_cache" "$_src_dir"
    "$_main_repo/utils/prune_binaries.py" "$_src_dir" "$_main_repo/pruning.list"
    #domain substitution
    "$_main_repo/utils/domain_substitution.py" apply -r "$_main_repo/domain_regex.list" -f "$_main_repo/domain_substitution.list" -c "$_root_dir/build/domsubcache.tar.gz" "$_src_dir"
    #applies chrome:// substitution
    "$_main_repo/utils/domain_substitution.py" apply -r "$_main_repo/url_regex.list" -f "$_main_repo/url_substitution.list" -c "$_root_dir/build/urlsubcache.tar.gz" "$_src_dir"

    #copies all files to src, should be only binares
    cp -a "$_main_repo/wip_src/src" "$_root_dir/build"
fi