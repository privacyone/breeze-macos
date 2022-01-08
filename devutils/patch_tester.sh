#!/bin/bash -eux

# Simple build script for macOS

_root_dir=$(dirname $(greadlink -f $0))
_download_cache="$_root_dir/build/download_cache" 
_src_dir="$_root_dir/build/src"
_main_repo="$_root_dir/core"
_breeze_patches="$_main_repo/patches/core/breeze"

# For packaging
_chromium_version=$(cat $_root_dir/core/chromium_version.txt)

mkdir -p "$_src_dir/out/Default"
mkdir -p "$_download_cache"

#change variables in Breeze patches
"$_main_repo/utils/var_replace.py"

if [[ ! -d build/src/chrome ]]
then
    "$_main_repo/utils/downloads.py" retrieve -i "$_main_repo/downloads.ini" "$_root_dir/downloads.ini" -c "$_download_cache"
    "$_main_repo/utils/downloads.py" unpack -i "$_main_repo/downloads.ini" "$_root_dir/downloads.ini" -c "$_download_cache" "$_src_dir"
    "$_main_repo/utils/prune_binaries.py" "$_src_dir" "$_main_repo/pruning.list"
	#domain substitution
	"$_main_repo/utils/domain_substitution.py" apply -r "$_main_repo/domain_regex.list" -f "$_main_repo/domain_substitution.list" -c "$_root_dir/build/domsubcache.tar.gz" "$_src_dir"
	#applies chrome:// substitution
	"$_main_repo/utils/domain_substitution.py" apply -r "$_main_repo/url_regex.list" -f "$_main_repo/url_substitution.list" -c "$_root_dir/build/urlsubcache.tar.gz" "$_src_dir"
	#applies all patches before domain substitution

	#copies all files to src, should be only binares
	cp -a "$_main_repo/stable_src/src" "$_root_dir/build"

fi

#copy original files over patched files
if [[ -d "$_root_dir/build/unpatched/" ]]
then
	cp -a "$_root_dir/build/unpatched/." "$_root_dir/build/src"
fi

#removes patch made files if they exist
"$_main_repo/utils/stable_patch_made_files_remover.py"

#saves original files before patching
"$_main_repo/utils/test_stable_patches.py"

#applies patches
"$_main_repo/utils/patches.py" apply "$_src_dir" "$_main_repo/patches" "$_root_dir/patches"

#copy original files over patched files
if [[ -d "$_root_dir/build/unpatched_breeze/" ]]
then
	cp -a "$_root_dir/build/unpatched_breeze/." "$_root_dir/build/src"
fi
#removes patch made files if they exist
"$_main_repo/utils/patch_made_files_remover.py"

#saves original files before patching
"$_main_repo/utils/test_patches.py"

#applies Breeze patches
"$_main_repo/utils/patches.py" apply "$_src_dir" "$_breeze_patches"

#copies all wip files to src, should be only binares
cp -a "$_main_repo/wip_src/src" "$_root_dir/build"
