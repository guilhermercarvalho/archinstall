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
#######################################################################################
#
#                                          Funções
#                                          -------
#
_ler_resposta() {
    if [[ ${resposta} =~ ^[sS]([iI][mM])*$ || ${resposta} = "" ]]; then
        return 0
    else
        return -1
    fi
}

_fim_msg() {
    echo
    echo '-------------------------------------------------------------------------------'
    echo
    sleep 2
}

_ping_internet() {
    echo "#############################"
    echo "# Testando conexão internet #"
    echo "#############################"
    echo
    ping -c 4 -q archlinux.org
    if [ $? -eq 0 ]; then
        printf "${grn_full}" "Conexão ativa!"
        return 0
    else
        printf "${red_full}" "Conexão inativa!"
        return -1
    fi
}

_efi_system() {
    # Formatar partições
    read -p "/dev/sda1: EFI System?[S/n]" resposta
    _ler_resposta
    if [ $? -eq 0 ]; then
        mkfs.fat -F32 /dev/sda1
    fi
    _fim_msg

    read -p "/dev/sda2: Linux filesystem?[S/n]" resposta
    _ler_resposta
    if [ $? -eq 0 ]; then
        mkfs.ext4 /dev/sda2
    fi
    _fim_msg

    # Montar sistema
    echo "################################"
    echo "# Montando raíz do sistema EFI #"
    echo "################################"
    mount /dev/sda2 /mnt
    mkdir -p /mnt/boot
    mount /dev/sda1 /mnt/boot
}

_legacy_system() {
    # Formatar partições
    read -p "/dev/sda1: Linux filesystem?[S/n]" resposta
    _ler_resposta
    if [ $? -eq 0 ]; then
        mkfs.ext4 /dev/sda1
    fi
    _fim_msg

    # Montar sistema
    echo "###################################"
    echo "# Montando raíz do sistema LEGACY #"
    echo "###################################"
    mount /dev/sda1 /mnt
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
#                               Início Pós-Instalação
#                               ------ --------------
#
# Instala interface gráfica
echo "####################################################################"
echo "# Selecione a interface gráfica a ser instalada (Apenas o número): #"
echo "#            1)GNOME                      2)KDE                    #"
echo "#                                                                  #"
read -p " # Interface: " interface
echo "####################################################################"

sudo pacman -S xorg xorg-xinit --noconfirm

case "${interface}" in
    1) sudo pacman -S gnome gnome-extra gnome-shell-extensions gnome-power-manager --noconfirm;;
    2) sudo pacman -S plasma kde-applications sddm --noconfirm;;
esac
_fim_msg

# Ativando gerenciador de login e internet para Gnome
case "${interface}" in
    1) sudo systemctl enable NetworkManager.service
    sudo systemctl enable gdm.service
    sudo sed -i 's:#.*WaylandEnable=false:WaylandEnable=false': /etc/gdm/custom.conf
    ;;
    2) sudo systemctl enable sddm.service ;;
esac

echo "######################"
echo "# Instalar YAY (AUR) #"
echo "######################"
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
cd ~
rm -rf yay/
yay -Syyuu --noconfirm
_fim_msg

echo 'Instalando minhas aplicações pacman e yay...'
#pacman -S cmatrix texlive-most flashplugin libreoffice-fresh libreoffice-fresh-pt-br linux-firmware util-linux virtualbox zsh-completions bluez bluez-utils android-tools gparted bash-completion gpick gimp inkscape lutris htop transmission-gtk vim vlc keepassxc --noconfirm
# pacman -S nano vim dhcpcd --noconfirm
#yay -S megasync gnome-shell-pomodoro stremio-beta dropbox jdk8-openjdk openjdk8-doc openjdk8-src codecs64 discord oh-my-zsh-git pamac-aur spotify visual-studio-code-bin --noconfirm
#yay -S visual-studio-code-bin --noconfirm

echo "#########################"
echo "# Install Audio Plugins #"
echo "#########################"
pacman -S alsa-lib alsa-utils alsa-oss pulseaudio pulseaudio-alsa --noconfirm
_fim_msg

echo "###########################"
echo "# Instalando Sublime Text #"
echo "###########################"
curl -O https://download.sublimetext.com/sublimehq-pub.gpg && sudo pacman-key --add sublimehq-pub.gpg && sudo pacman-key --lsign-key 8A8F901A && rm sublimehq-pub.gpg
echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu sublime-text --noconfirm
_fim_msg

# configurar propriedades git
echo "Configurando git..."
git config --global user.name "Guilherme Carvalho"
git config --global user.email "guilhermercarvalho512@gmail.com"

# confiurar chave de acesso SSH
#echo "Gerando chave de acesso SSH..."
#ssh-keygen
#echo "Copy your public key."
_fim_msg

sudo rm -rf archinstall

echo "#########################"
echo "# Reiniciando o sistema #"
echo "#########################"
_fim_msg
reboot

# sed 's:# alias zshconfig:alias zshconfig: ; s:# alias ohmyzsh:alias ohmyzsh: ; s:"mate ~\/:"vim ~\/': .zshrc