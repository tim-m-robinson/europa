#!/usr/bin/env bash
#
# Copyright 2015 - gatblau.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# EUROPA Source to Image script core installation script.
#

startTime=$(date -u +"%s")

echo 'downloading build scripts'
git clone https://github.com/gatblau/europa.git

echo 'determining the latest version'
cd europa
tag='development'
echo $tag >> build/roles/europa/files/shell/version
echo "version is $tag"

echo 'switching to latest version'
git checkout $tag

echo 'dowloading Europa packages, please wait...'
cd build
sh fetch.sh
cd ..

echo 'building Europa image, please wait...'
../packer_files/packer build europa.vbox.json

echo 'backing up the Europa Open Virtual Appliance to the Appliances directory'
mkdir -p c:/Appliances
cp -v europa-vbox/europa.ova c:/Appliances/europa_$tag.ova

echo 'importing the Europa appliance into Virtual Box, please wait...'
VBoxManage import c:/Appliances/europa_$tag.ova

read -n1 -p "Do you want to delete the installation files? [Y-N]" deleteFiles
case $deleteFiles in
    [Yy]* ) cd .. && rm -rf * ;;
    * ) echo "installation files can be found at $PWD" ;;
esac

endTime=$(date -u +"%s")
diff=$(($endTime-$startTime))

echo "Europa build process complete: it took $(($diff / 60)) minutes and $(($diff % 60)) seconds."

echo 'Launching Virtual Box...'
echo 'Remember to adjust the VM settings before starting it!'

(VirtualBox &)

read -p "Press any key to close the console..."

exit