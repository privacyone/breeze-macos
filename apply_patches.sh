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


"$_main_repo/utils/patches.py" combine "$_main_repo/patches" "$_root_dir/patches" "$_breeze_patches" "$_temp_patches"

#change variables in patches
"$_main_repo/utils/var_replace.py"

if [[ ! -d "$_saved_patches" ]]
then
	"$_main_repo/utils/patch_made_files_remover.py"

	#saves original files before patching
	"$_main_repo/utils/save_original_files.py"
fi

"$_main_repo/utils/patches.py" compare "$_saved_patches" "$_temp_patches" "$_src_dir"

cp -a "$_temp_patches/" "$_saved_patches/"
rm -rf "$_temp_patches/"

"$_main_repo/utils/set_version.py" "$_src_dir" "$_main_repo/breeze_version.txt"

cp -a "$_main_repo/wip_src/src" "$_root_dir/build"
