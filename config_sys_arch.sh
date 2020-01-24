#!/usr/bin/env bash
#
# config_sys_arch.sh - Configuração do sistema Arch Linux
#
# Site  : https://github.com/guilhermercarvalho/archinstall
# Autor : Guilherme Carvalho <guilhermercarvalho512@gmail.com>
#
# -------------------------------------------------------------------------------------
#
# Este programa executa a configuração do Arch Linux instalado em seu dispositivo
#
# -------------------------------------------------------------------------------------
#
# Histórico:
#
#   v1.0 2019-10-21, Guilherme Carvalho:
#       - Versão inicial do programa
#   v1.1 2020-1-24, Guilherme Carvalho:
#       - Refatoração de código
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
#       $USUARIO            Usuário do sistema
# 
# --------------------------------------------------------------------------------------
# Configuração
IDIOMA_TECLADO=$(find /usr/share/kbd/keymaps/**/* -iname br-abnt2.map.gz | head -n 1)
TIMEZONE=$(find /usr/share/zoneinfo/**/* -iname Sao_Paulo | head -n 1)
NOME_HOST="arch"

# Usuario sudo
USUARIO='guilherme'

# Cores
red_full=$'\e[1;31m%s\e[0m\n'
grn_full=$'\e[1;32m%s\e[0m\n'
yel_full=$'\e[1;33m%s\e[0m\n'
blu_full=$'\e[1;34m%s\e[0m\n'
mag_full=$'\e[1;35m%s\e[0m\n'
cyn_full=$'\e[1;36m%s\e[0m\n'

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

# Boot do sistema
BOOT_EFI=0
BOOT_LEGACY=0

# Dispotivo
DEV=''

#######################################################################################
#
#                           Início Configuração do Sistema
#                           ------ ------------ -- -------
#
echo "Definindo timezone"
ln -sf "${TIMEZONE}" /etc/localtime # São Paulo por padrão
hwclock --systohc --utc

echo "Definindo layout do teclado"
sed -i 's/#pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g;s/#pt_BR ISO-8859-1/pt_BR ISO-8859-1/g' /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
export LANG=pt_BR.UTF-8

echo "Definindo idioma"
echo "KEYMAP="${IDIOMA_TECLADO}"" >> /etc/vconsole.conf

echo "Configurando hosts e resolv"
echo "$NOME_HOST" >> /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t"${NOME_HOST}".localdomain "${NOME_HOST}"" >> /etc/hosts
echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" > /etc/resolv.conf

echo "Instalando reflector"
yes no | pacman -Syyuuq
pacman -Sq reflector --noconfirm

echo "Encontrando espelhos do pacman mais recentes no Brasil"
reflector --country Brazil --age 12 --protocol http --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyuuq --noconfirm

echo "Defina a senha de root"
passwd

echo "Criando usuário ${USUARIO}"
useradd -m -G wheel -s /bin/bash ${USUARIO}
passwd ${USUARIO}
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

fdisk -l
sleep 5

echo "Selecione o seu dispositivo:"
read DEV

echo "Configurando boot do sistema"
if [ -d /sys/firmware/efi/efivars ]; then
    # Configurando systemd-boot
    bootctl --path=/boot install
    echo -e "default  arch\n#timeout  3\nconsole-mode max\neditor   no" > /boot/loader/loader.conf
    echo -e "title   Arch Linux\nlinux   /vmlinuz-linux\ninitrd  /intel-ucode.img\ninitrd  /initramfs-linux.img\noptions root=PARTUUID=$(blkid /dev/sd${DEV}2 | sed "s/.*PARTUUID=//g" | cut -d\" -f2) rw" > /boot/loader/entries/arch.conf
else
    # "Configurando grub"
    pacman -Sq grub os-prober --noconfirm
    grub-install /dev/sd${DEV}
    grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "Iniciando Post Install Arch..."
su -c "sh /archinstall/post_install_arch.sh" ${USUARIO}

exit 0
