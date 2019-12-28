#!/usr/bin/env bash
#
# pre_install_arch.sh - Pre-Instalação do Arch Linux
#
# Site  : https://github.com/guilhermercarvalho/archinstall
# Autor : Guilherme Carvalho <guilhermercarvalho512@gmail.com>
#
# -------------------------------------------------------------------------------------
#
# Este programa executa a pré-instalção do Arch Linux em seu sistema
#
# -------------------------------------------------------------------------------------
#
# Histórico:
#
#   v1.0 2019-10-21, Guilherme Carvalho:
#       - Versão inicial do programa em execução sem tratamento de erros
#
#
# Licença: -
#
#
#######################################################################################
#
#                                     Configuração
#                                     ------------
#
# Configuração das variáveis de ambiente
#
#       $IDIOMA_TECLADO     Keymap utilizado, padrão "br-abnt2").
#       $TIMEZONE           Configura fuso, padrão "Sao_Paulo".
#       $NOME_HOST          Nome da máquina.
# 
# --------------------------------------------------------------------------------------
# Configuração
IDIOMA_TECLADO=$(find /usr/share/kbd/keymaps/**/* -iname br-abnt2.map.gz | head -n 1)
TIMEZONE=$(find /usr/share/zoneinfo/**/* -iname Sao_Paulo | head -n 1)
NOME_HOST="arch"

# Boot do sistema
BOOT_EFI=0
BOOT_LEGACY=0
#
#
#######################################################################################
#
#                                   Funções
#                                   -------
#
_fim_msg() {
    echo
    echo '-------------------------------------------------------------------------------'
    echo
    sleep 2
}

_espera_confimacao() {
    echo "Continuar?"
    read
}
_efi_system() {
    # Configurando systemd-boot
    bootctl --path=/boot install
    echo -e "default  arch\n#timeout  3\nconsole-mode max\neditor   no" > /boot/loader/loader.conf
    echo -e "title   Arch Linux\nlinux   /vmlinuz-linux\ninitrd  /intel-ucode.img\ninitrd  /initramfs-linux.img\noptions root=PARTUUID=$(blkid /dev/sda2 | sed "s/.*PARTUUID=//g" | cut -d\" -f2) rw" > /boot/loader/entries/arch.conf
}

_legacy_system() {
    # Configura gerenciador de boot do sistema
    echo "Configure o boot da máquina"
    pacman -S grub os-prober --noconfirm
    grub-install /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
}
#
#
#######################################################################################
#
#                           Início Configuração do Sistema
#                           ------ ------------ -- -------
#
# Define tipo de boot disponível (UEFI ou Legacy)
if [ -d /sys/firmware/efi/efivars ]; then
    echo "###################"
    printf "%s\n" "# UEFI ${grn}disponível${end} #"
    echo "###################"
    BOOT_EFI=1
else
    echo "####################################"
    printf "%s\n" "# UEFI ${red}indisponível${end}, usando ${yel}LEGACY${end} #"
    echo "####################################"
    BOOT_LEGACY=1
fi
_fim_msg

# Define fuso horário
echo "######################"
echo "# Definir horário #"
echo "######################"
ln -sf "${TIMEZONE}" /etc/localtime # São Paulo por padrão
hwclock --systohc --utc
_fim_msg

# Define idioma do sistema e do teclado
echo "################################"
echo "# Definir localização e idioma #"
echo "################################"
sed -i 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g;s/#pt_BR ISO-8859-1/pt_BR ISO-8859-1/g' /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
export LANG=pt_BR.UTF-8
echo "KEYMAP="${IDIOMA_TECLADO}"" >> /etc/vconsole.conf
_fim_msg

# Configura etc/hostname
echo "#######################"
echo "# Configurar internet #"
echo "#######################"
echo "$NOME_HOST" >> /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t"${NOME_HOST}".localdomain "${NOME_HOST}"" >> /etc/hosts
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf
_fim_msg

# Atualizando pacman e instalando reflector
echo "########################"
echo "# Instalando reflector #"
echo "########################"
pacman -Syyuu
pacman -S reflector --noconfirm
_fim_msg

echo "####################################"
echo "# Procurando por melhores espelhos #"
echo "####################################"
reflector --country Brazil --age 12 --protocol http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyuu nano vim bash-completion --noconfirm
_fim_msg

# Define senha de root
echo "#########################"
echo "# Definir senha de root #"
echo "#########################"
passwd

# Cria usuário sudo
echo "######################"
echo "# Criar usuário sudo #"
echo "######################"
useradd -m -G wheel -s /bin/bash guilherme
passwd guilherme
sed -i 's/#%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers
_fim_msg

systemctl enable dhcpcd.service

if [ ${BOOT_EFI} -eq 1 ]; then
    _efi_system
elif [ ${BOOT_LEGACY} -eq 1 ]; then
    _legacy_system
fi
_fim_msg

echo "Desmonte as partições e reinicie"
echo

exit 0