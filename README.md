# Breeze for macOS

macOS packaging for [Breeze](//breeze-core).

## Building

This section will explain in detail how to build Breeze for macOS.
The building process is very similiar to building [ungoogled-chromium-macos](https://github.com/ungoogled-software/ungoogled-chromium-macos).
If you encounter any problem while following this tutorial, feel free to open an issue. 

### Setting up the build environment
##### 0. Mac Requirements
* Mac running macOS 10.15.4 or later. Building chromium is a demanding process. It is recommended to have at least 8 GB of RAM, a high-end CPU to avoid a very long building time. Additionally, ~20GB of space will be needed to complete the whole build process. 
##### 1. Xcode 12.2+
* Download Xcode using [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835) or [Apple Developer Software Downloads page](https://developer.apple.com/download/release/).
##### 2. Homebrew
* Install [Homebrew](https://brew.sh/) running the following command in macOS terminal:
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
##### 3. Pearl
* Install [Pearl](https://www.perl.org/) running the following command in macOS terminal:
   ```
   curl -L http://xrl.us/installperlosx | bash
   ```
##### 4. Python
* Install latest Python 3 running the following command in macOS terminal: `brew install python`
* Install Python's pyenv to manage python version:  `brew install pyenv`
* Install Python 2.7.16: `pyenv install 2.7.16`
* Setup `pyenv`:
   ```sh
   echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
   ```
* Set global `python` command to use Python 2.7.16: `pyenv global 2.7.16`.
##### 5. Node.js
* Install Node.js: `brew install node`
### Building

Run macOS terminal, change the current directory to the one in which you wish to build Breeze and run the following commands:

##### Cloning the repository
```
git clone https://github.com/privacyone/breeze-macos.git
git submodule update --recursive --init
```
This will make a local main repository with all needed subrepositories.
##### Preparing chromium source files

```
sh prepare_build.sh
```
This will download and unpack archived chromium source files and required tools, `prune_binaries` and apply `domain_substitution` and `url_substitution` on the unpacked code. If no errors are encountered, this script should be run only once. If it fails, delete everything but `downloads_cache` in build folder and run `prepare_build.sh` again.

##### Applying patches
```
sh apply_patches.sh
```
If no previous patches have been applied, this will apply all Windows specific and core patches. Otherwise, it will only apply updated patches.

##### Building
```
sh build.sh
```
This will start the build process. If it fails, you can fix the code, run the `build.sh` again and it will continue the build process from where it previously failed.

Once the build passes successfully, Breeze `.dmg` file will be copied to `out` folder.

## License

See [LICENSE](LICENSE)
