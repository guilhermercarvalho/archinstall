wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo apt-get -y install apt-transport-https
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt-get update && sudo apt-get install sublime-text

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install code

curl -sS https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client

wget -c -O /tmp/stremio.deb $(curl -s https://www.stremio.com/downloads | grep -Eo 'https:\/\/dl\.strem\.io\/linux\/.*\/.*\.deb')
sudo dpkg -i /tmp/stremio.deb

wget -c -O /tmp/dropbox.deb https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2019.02.14_amd64.deb
sudo dpkg -i /tmp/dropbox.deb

wget -c -O /tmp/mega.deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/amd64/megasync-xUbuntu_18.04_amd64.deb
sudo dpkg -i /tmp/mega.deb

wget -c -P /tmp/ https://steamcdn-a.akamaihd.net/client/installer/steam.deb
sudo dpkg -i /tmp/steam.deb

sudo apt-get install ffmpeg
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt-get update && sudo apt-get install obs-studio

wget -c -O /tmp/discord.deb https://dl.discordapp.net/apps/linux/0.0.9/discord-0.0.9.deb
sudo dpkg -i /tmp/discord.deb

#sudo apt install -y android-tools chromium cmatrix gimp git gparted gpick gzip htop inkscape jdk8-openjdk keepassxc neofetch net-tools ntfs-3g openjdk8-doc openjdk8-src openjdk-doc openjdk-src p7zip python-pip qbittorrent sox unrar vim vlc wine youtube-dl