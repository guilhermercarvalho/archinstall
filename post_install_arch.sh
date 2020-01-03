#!/usr/bin/env bash
#
# post_install_arch.sh - Instala e configura o novo ambiente Arch Linux recém instalado
#
# Site  : https://github.com/guilhermercarvalho/archinstall
# Autor : Guilherme Carvalho <guilhermercarvalho512@gmail.com>
#
# -------------------------------------------------------------------------------------
#
# Este programa instala os programas que utilizo no meu dia-a-dia e realiza
# configurações do sistema de minha preferência.
#
# -------------------------------------------------------------------------------------
#
# Histórico:
#
#   v1.0 2019-08-01, Guilherme Carvalho:
#       - Versão inicial do programa
#
#
# Licença: -
#
#######################################################################################
#
#                                          Funções
#                                          -------
#
_fim_msg() {
    echo
    echo '-------------------------------------------------------------------------------'
    echo
    sleep 2
}
#
#
#######################################################################################
#
#                                     Menssagem
#                                     ---------
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
#
#
#######################################################################################
#
#                                Messagem de Boas-Vindas
#                                -------- -- -----------
#
echo "############################################################"
echo "#                                                          #"
echo "# Bem-Vindo a Pós-Configuração da Instalação do Arch Linux #"
echo "#                                                          #"
echo "############################################################"
_fim_msg
#
#
#######################################################################################
# 
#                               Início Pós-Instalação
#                               ------ --------------
#
echo "#################################"
echo "# Habilitando aplicações 32-bit #"
echo "#################################"
sudo sed -zi 's/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/g' /etc/pacman.conf

# Instala interface gráfica
echo "####################################################################"
echo "# Selecione a interface gráfica a ser instalada (Apenas o número): #"
echo "#            1)GNOME                      2)KDE                    #"
echo "####################################################################"
echo
read -p "Interface: " interface

sudo pacman -Syyuu xorg xorg-xinit intel-media-driver mesa lib32-mesa vulkan-intel --noconfirm

case "${interface}" in
    1)
        sudo pacman -S gnome gnome-extra gnome-shell-extensions gnome-power-manager --noconfirm
        ;;
    2)
        sudo pacman -S plasma sddm --noconfirm
        echo -e "4 5 13 14 17 18 19 20 21 24 25 31 32 36 38 45 49 50 52 53 54 59 60 63 71 77 78 86 105 121 137 144 147 149\nS" | sudo pacman -S kde-applications
        sudo pacman -S kdeplasma-addons plasma-nm plasma-pa breeze-gtk breeze-kde4 kde-gtk-config cups powerdevil baloo kdeconnect colord-kde ttf-dejavu ttf-liberation --noconfirm
        echo "exec startkde" > ~/.xinitrc
        ;;
esac
_fim_msg

echo "########################"
echo "# Instalando YAY (AUR) #"
echo "########################"
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
cd ${HOME}
rm -rf yay/
yay -Syyuu --noconfirm
_fim_msg

echo "############################"
echo "# Minhas aplicações PACMAN #"
echo "############################"
sudo pacman -S android-tools networkmanager bluez-utils chromium cmatrix cups discord firefox firefox-i18n-pt-br gparted gpick gimp htop inkscape jdk8-openjdk keepassxc libreoffice-fresh libreoffice-fresh-pt-br neofetch obs-studio openjdk-doc openjdk-src openjdk8-doc openjdk8-src p7zip unrar tar sox steam speedtest-cli wine vlc virtualbox qbittorrent --noconfirm
_fim_msg

echo "#########################"
echo "# Minhas aplicações AUR #"
echo "#########################"
yay -S codecs64 dropbox megasync pamac-aur skypeforlinux-stable-bin stremio-beta visual-studio-code-bin --noconfirm
_fim_msg

echo "###############################"
echo "# Instalando plugins de audio #"
echo "###############################"
sudo pacman -S alsa-lib alsa-utils alsa-oss pulseaudio pulseaudio-alsa --noconfirm
_fim_msg

echo "###########################"
echo "# Instalando Sublime Text #"
echo "###########################"
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu sublime-text --noconfirm
_fim_msg

echo "##################################"
echo "# Habilitando suporte a Internet #"
echo "##################################"
sudo systemctl disable dhcpcd.service
sudo systemctl enable NetworkManager.service

# Ativando gerenciador de login e internet para Gnome
case "${interface}" in
    1)
        sudo systemctl enable gdm.service
        sudo sed -i 's:#.*WaylandEnable=false:WaylandEnable=false': /etc/gdm/custom.conf
        echo -e 'headerbar.default-decoration {\npadding-top: 3px;\npadding-bottom: 3px;\nmin-height: 3px;\nfont-size: 1em;\n}\n\nheaderbar.default-decoration button.titlebutton {\npadding: 3px;\nmin-height: 3px;\n}' > ${HOME}/.config/gtk-3.0/gtk.css
        ;;
    2)
        sudo systemctl enable sddm.service
        ;;
esac

echo "############################"
echo "# Habilitando suporte TRIM #"
echo "############################"
sudo systemctl enable fstrim.timer
_fim_msg

echo "#########################"
echo "# Habilitando Bluetooth #"
echo "#########################"
sudo systemctl enable bluetooth.service

echo "#####################################"
echo "# Habilitando suporte a impressoras #"
echo "#####################################"
sudo systemctl enable org.cups.cupsd.service
_fim_msg

echo "####################"
echo "# Configurando git #"
echo "####################"
git config --global user.name "Guilherme Carvalho"
git config --global user.email "guilhermercarvalho512@gmail.com"
_fim_msg

echo "#############################"
echo "# Removendo archinstal de / #"
echo "#############################"
sudo rm -rf /archinstall
_fim_msg

echo "#########################"
echo "# Reiniciando o sistema #"
echo "#########################"
_fim_msg
reboot