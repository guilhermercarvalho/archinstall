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
arch-chroot /mnt /bin/bash

# Define fuso horário
echo "Setar TIMEZONE"
ln -sf "$TIMEZONE" /etc/localtime # São Paulo por padrão
hwclock --systohc

# Define idioma do sistema e do teclado
echo "Definir localização e idioma"
sed -i 's:#pt_BR.UTF-8 UTF-8:pt_BR.UTF-8 UTF-8 ; s:#pt_BR ISO-8859-1:pt_BR ISO-8859-1': /etc/locale.gen
locale-gen
echo "LANG=pt_BR.UTF-8" >> /etc/locale.conf
echo "KEYMAP="$IDIOMA_TECLADO"" >> /etc/vconsole.conf

# Configura etc/hostname
echo "Configurar Internet"
echo "$NOME_HOST" >> /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\t\tlocalhost\n127.0.1.1\t"$NOME_HOST".localdomain "$NOME_HOST"" >> /etc/hosts

# Atualiza Sistema
echo "Update Pacman System"
pacman -Syyuu

# Define senha de root
echo "Definir senha de root"
passwd

# Configura gerenciador de boot do sistema
echo "Configure o boot da máquina"
pacman -S grub os-prober

grub-install /dev/sda

grub-mkconfig -o /boot/grub/grub.cfg

exit 0