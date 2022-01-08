#!/bin/bash -eux

# Does domain and url sub on patches, useful when updating with ungoogled patches

_root_dir=$(dirname $(greadlink -f $0))
_download_cache="$_root_dir/build/download_cache" 
_src_dir="$_root_dir/build/src"
_temp_patches="$_root_dir/build/temp_patches"
_saved_patches="$_root_dir/build/saved_patches"
_main_repo="$_root_dir/core"
_breeze_patches="$_main_repo/patches/core/breeze"

#domain substitution
"$_main_repo/utils/domain_substitution.py" apply -r "$_main_repo/domain_regex.list" -f "$_main_repo/patches/series" -c "$_main_repo/patches/domsubcache.tar.gz" "$_main_repo/patches"
#applies chrome:// substitution
"$_main_repo/utils/domain_substitution.py" apply -r "$_main_repo/url_regex.list" -f "$_main_repo/patches/series" -c "$_main_repo/patches/urlsubcache.tar.gz" "$_main_repo/patches"
