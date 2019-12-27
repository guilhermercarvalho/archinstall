#!/usr/bin/env bash
#
# post_install_arch.sh - Instala e configura o novo ambiente Arch Linux recém instalado
#
# Site  : https://github.com/guilhermercarvalho/archinstall
# Autor : Guilherme Carvalho <guilhermercarvalho512@gmail.com>
#
# -------------------------------------------------------------------------------------
#
# Este programa instala os programas básicos que utilizo no meu dia-a-dia e realiza
# configurações do sistema de minha preferência.
#
# -------------------------------------------------------------------------------------
#
# Histórico:
#
#   v1.0 2019-08-01, Guilherme Carvalho:
#       - Versão inicial do programa em execução sem tratamento de erros
#
#
# Licença: -
#

echo '-----------------------------------------------------------------------------------'
echo '     ____             __     ____           __        ____   ___              __   '
echo '    / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /  /   |  __________/ /_  '
echo '   / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __ `/ / /  / /| | / ___/ ___/ __ \ '
echo '  / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /  / ___ |/ /  / /__/ / / / '
echo ' /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/  /_/  |_/_/   \___/_/ /_/  '
echo '                                                                                   '
echo '                     Por Guilherme Carvalho - https://github.com/guilhermercarvalho'
echo '-----------------------------------------------------------------------------------'



# instala interfaces
echo "Selecione a interface gráfica a ser instalada (Apenas o número):"
echo -e "1)GNOME \t2)KDE\t3)Xfce\t4)LXQt"
echo ":"
read interface
case "$interface" in
    1) sudo pacman -S gnome gnome-extra gnome-shell-extensions gnome-power-manager --noconfirm;;
    2) sudo pacman -S plasma --noconfirm;;
    3) sudo pacman -S xfce4 xfce4-goodies --noconfirm;;
    4) sudo pacman -S lxqt --noconfirm;;
esac

# ativando interface
if [[ $interface == 1 ]]; then
    echo "Ativando NetworkManager e GDM"
    sudo systemctl enable NetworkManager.service
    sudo systemctl enable gdm.service
    sudo sed -i 's:#.*WaylandEnable=false:WaylandEnable=false': /etc/gdm/custom.conf
else
    echo "GNOME não selecionado!"
fi

echo "Instalando YAY"
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
cd && rm -r yay/

echo "Atualiza repo"
sudo pacman -Syyuu --noconfirm
yay -Syyuu --noconfirm

echo 'Instalando minhas aplicações pacman e yay...'
sudo pacman -S cmatrix texlive-most flashplugin libreoffice-fresh libreoffice-fresh-pt-br linux-firmware util-linux virtualbox zsh-completions bluez bluez-utils android-tools gparted bash-completion gpick gimp inkscape lutris htop transmission-gtk vim vlc keepassxc --noconfirm
yay -S megasync gnome-shell-pomodoro stremio-beta dropbox jdk8-openjdk openjdk8-doc openjdk8-src codecs64 discord oh-my-zsh-git pamac-aur spotify visual-studio-code-bin --noconfirm

echo "Install Audio Plugins"
pacman -S alsa-lib alsa-utils alsa-oss pulseaudio pulseaudio-alsa

echo "Instalando Sublime Text"
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu sublime-text --noconfirm

# configurar propriedades git
echo "Configurando git..."
git config --global user.name "Guilherme Carvalho"
git config --global user.email "guilhermercarvalho512@gmail.com"

# confiurar chave de acesso SSH
echo "Gerando chave de acesso SSH..."
ssh-keygen
echo "Copy your public key."



# sed 's:# alias zshconfig:alias zshconfig: ; s:# alias ohmyzsh:alias ohmyzsh: ; s:"mate ~\/:"vim ~\/': .zshrc