#!/bin/bash
# by: William Trelawny (williamtrelawny / willman42)


### TODO:
# - Perform remote vs local version check before downloading Oxide


### Sanity Checks:
# Exit if Rust server is already running:
[ $(ps -ef | grep RustDedicated | wc -l) -ge 2 ] && echo -e "Please stop Rust Dedicated server before performing Oxide upgrade! Exiting... \n" && exit 1

### Install Dependencies based on which package manager used:
DEPS='curl unzip'
while true
do
  [ -x "$(command -v apt)" ] && sudo apt install $DEPS && break
  [ -x "$(command -v apt-get)" ] && sudo apt-get install $DEPS && break
  [ -x "$(command -v yum)" ] && sudo yum install $DEPS && break
  [ -x "$(command -v dnf)" ] && sudo dnf install $DEPS && break
  [ -x "$(command -v zypper)" ] && sudo zypper install $DEPS && break
  [ -x "$(command -v apk)" ] && sudo apk add --no-cache $DEPS && break
  echo -e "No supported package manager found! Currently supported are: apt apt-get yum dnf zyppoer zpk. Exiting..." && exit 1
done


### RDS Installation Discovery:
# Get RustDedicated_data location(s), set RUSTDIR to parent directory of each:
RUSTDIR=($(sudo find / -ignore_readdir_race -type d -name RustDedicated_Data))
RUSTDIR=($(for i in ${RUSTDIR[@]}; do echo ${i%/*}; done))

# If multiple folders are found, allow user to select which to use:
if [ "${#RUSTDIR[@]}" -gt 1 ]; then
  PS3="Multiple Rust Dedicated Server installations found, please choose which to install Oxide on: "
  select i in "${RUSTDIR[@]}"
  do
    [[ $REPLY -gt "${#RUSTDIR[@]}" || $REPLY -lt 1 ]] && echo -e "Invalid option\n"
    [[ $REPLY -gt 0 && $REPLY -le "${#RUSTDIR[@]}" ]] && echo "You selected: $i" && RUSTDIR=$i && break
  done
fi

# If no folders are found, prompt user to add the path manually:
[ -z $RUSTDIR ] && read -p 'Rust Dedicated Server install directory could not be found! Specify it manually here or escape this script: ' RUSTDIR


### Oxide Update:
# Fetch latest Oxide update (currently the `develop` branch but may change to `master`):
curl -JL -o /tmp/Oxide.Rust-linux.zip https://umod.org/games/rust/download/develop

# Install Oxide:
unzip -o /tmp/Oxide.Rust-linux.zip -d $RUSTDIR

# Cleanup:
rm -rf /tmp/Oxide.Rust-linux.zip


# Done
echo -e "Oxide has been updated! You can now restart your Rust server.\n"
