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
#   v1.1 2020-1-24, Guilherme Carvalho:
#       - Refatoração de código
#
#
# Licença: -
#
#######################################################################################
#
#                                       Pacotes Pacman
#                                       ------- ------
#
GRAPHC_PKG="xorg xorg-xinit intel-gmmlib intel-media-driver intel-media-sdk intel-tbb intel-ucode mesa lib32-mesa vulkan-intel xdg-user-dirs"
#MY_PKG="android-tools bash-completion cmatrix discord git gparted keepassxc obs-studio qbittorrent speedtest-cli steam vlc"
#REDE_PKG="networkmanager net-tools ufw"
#IMPRESSORA_PKG="cups cups-filters"
#BLUETOOTH_PKG="bluez bluez-utils"
#NAVEGADOR_PKG="chromium firefox firefox-i18n-pt-br"
#SISTEMA_PKG="htop neofetch"
#IMAGEM_PKG="gpick gimp inkscape"
#JAVA_PKG="jdk8-openjdk openjdk-doc openjdk-src openjdk8-doc openjdk8-src"
#EMU_PKG="wine virtualbox virtualbox-host-dkms"
#COMPRIME_EXTRAI_PKG="p7zip unrar tar"
#AUDIO_PKG="alsa-lib alsa-utils alsa-oss pulseaudio pulseaudio-alsa sox"
#OFFICE_PKG="libreoffice-fresh libreoffice-fresh-pt-br"
#DOCKER_PKG="docker docker-compose"
#
#
#######################################################################################
#
#                                           Funções
#                                           -------
#
_yay_install() {
    cd ${HOME}
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si
    cd ${HOME}
    rm -rf yay/
    yay -Syyuu --noconfirm
}

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
#
#
#######################################################################################
# 
#                               Início Pós-Instalação
#                               ------ --------------
#
echo "Habilitando aplicações 32-bit nos repositórios pacman"
sudo sed -zi 's/#\[multilib\]\n#Include = \/etc\/pacman.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman.d\/mirrorlist/g' /etc/pacman.conf

# Instala interface gráfica
cat << EOF
Selecione a interface gráfica a ser instalada (Apenas o número):
            1)GNOME         2)KDE           3)XFCE

EOF
read -p "Interface: " interface

sudo pacman -Syyuuq  ${GRAPHC_PKG} --needed --noconfirm

case "${interface}" in
    1)
        sudo pacman -Sq gnome gnome-extra gnome-shell-extensions gnome-power-manager --needed --noconfirm
        ;;
    2)
        sudo pacman -Sq plasma sddm --needed --noconfirm
        echo -e "4 5 13 14 17 18 19 20 21 24 25 31 32 36 38 45 49 50 52 53 54 59 60 63 71 77 78 86 105 121 137 144 147 149\nS" | sudo pacman -Sq kde-applications
        sudo pacman -S kdeplasma-addons plasma-nm plasma-pa breeze-gtk breeze-kde4 kde-gtk-config cups powerdevil baloo kdeconnect colord-kde ttf-dejavu ttf-liberation --needed --noconfirm
        echo "exec startkde" > ~/.xinitrc
        ;;
esac

echo "Instalando alguns pacotes através do pacman"
#sudo pacman -Sq ${MY_PKG} ${REDE_PKG} ${IMPRESSORA_PKG} ${BLUETOOTH_PKG} ${NAVEGADOR_PKG} ${SISTEMA_PKG} ${IMAGEM_PKG} ${JAVA_PKG} ${EMU_PKG} ${COMPRIME_EXTRAI_PKG} ${AUDIO_PKG} ${OFFICE_PKG} ${AUDIO_PKG} ${DOCKER_PKG} --needed --noconfirm
sudo pacman -S --needed --noconfirm - < /archinstall/packages.txt

echo "Instalando Sublime Text"
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syuq sublime-text --noconfirm

echo "Instalando YAY (AUR)"
_yay_install

echo "Verificando instalação do yay"
yay --version
if [$? -eq 0]; then
    echo "Instalando alguns pacotes através do pacman"
    yay -Sq codecs64 dropbox megasync pamac-aur skypeforlinux-stable-bin stremio-beta visual-studio-code-bin --needed --noconfirm
else
    echo -e "Instalção yay mal sucedida :(\n"
fi

echo "Habilitando serviços de rede"
sudo systemctl enable NetworkManager.service
sudo systemctl enable ufw.service

echo "Habilitando gerenciador de login"
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

echo "Habilitando suporte TRIM"
sudo systemctl enable fstrim.timer

echo "Habilitando Bluetooth"
sudo systemctl enable bluetooth.service

echo "Habilitando suporte a impressoras"
sudo systemctl enable org.cups.cupsd.service

echo "Configurando git"
git config --global user.name "Guilherme Carvalho"
git config --global user.email "guilhermercarvalho512@gmail.com"

echo "Removendo pasta archinstall"
#sudo rm -rf /archinstall

echo "Instalação finalizada, por favor, reinicie a máquina"

exit 0