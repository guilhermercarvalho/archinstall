
#!/usr/bin/env bash
#
# pre_install_arch.sh - Pre-Instalação do Arch Linux
#
# Site  : https://github.com/guilhermercarvalho/archinstall
# Autor : Guilherme Carvalho <guilhermercarvalho512@gmail.com>
#
# -------------------------------------------------------------------------------------
#
# Este programa executa a instalção do Arch Linux em seu sistema
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
#                                     Menssagem
#                                     ---------
#
echo '-------------------------------------------------------------------------------'
echo '     ____               ____           __        ____   ___              __    '
echo '    / __ \________     /  _/___  _____/ /_____ _/ / /  /   |  __________/ /_   '
echo '   / /_/ / ___/ _ \    / // __ \/ ___/ __/ __ `/ / /  / /| | / ___/ ___/ __ \  '
echo '  / ____/ /  /  __/  _/ // / / (__  ) /_/ /_/ / / /  / ___ |/ /  / /__/ / / /  '
echo ' /_/   /_/   \___/  /___/_/ /_/____/\__/\__,_/_/_/  /_/  |_/_/   \___/_/ /_/   '
echo '                                                                               '
echo '                 Por Guilherme Carvalho - https://github.com/guilhermercarvalho'
echo '-------------------------------------------------------------------------------'
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
#   
#                                  Tipo de Boot
#                                  ---- -- ----
#       $BOOT_UFEI          Suporte para boot do tipo UEFI
#       $BOOT_LEGACY        Suporte para boot do tipo LEGACY
#
# -------------------------------------------------------------------------------------
#
IDIOMA_TECLADO=$(find /usr/share/kbd/keymaps/**/* -iname br-abnt2.map.gz | head -n 1)
TIMEZONE=$(find /usr/share/zoneinfo/**/* -iname Sao_Paulo | head -n 1)
NOME_HOST="arch"
BOOT_UFEI=0
BOOT_LEGACY=0
PRE_CONFIGURADO=1

#######################################################################################
#
#                                Messagem de Boas-Vindas
#                                -------- -- -----------
#
echo "Bem-Vindo a Pré-Configuração Inicial de Instalação do Arch Linux"
echo
echo "Este programa pressupõe que você tenha baixado, bootado e inciado a ISO do sistema."
read -p "Correto?[S/n] " resposta
if [[ $resposta =~ ^[sS]([iI][mM])*$ ]]; then
    resposta=
    echo
    echo "Perfeito! Deseja definir explicitamente os parâmetos de instalação?[S/n] "
    read resposta
    if [[ $resposta =~ ^[sS]([iI][mM])*$ ]]; then
        resposta=
        echo
        echo "OK!"
        PRE_CONFIGURADO=0
    fi
else
    echo
    echo "Execute install_iso_arch.sh"
    echo
fi
#######################################################################################
# 
#                               Iniciando Instalação
#                               --------- ----------
#
# Define layout do teclado
echo "Definindo Teclado para padrão ABNT2"
loadkeys $IDIOMA_TECLADO

# Define tipo de boot disponível (Legacy ou UEFI)
if [ -d ls /sys/firmware/efi/efivars ]; then
    echo "Sua máquina está configurada com o sistema UEFI"
    BOOT_UFEI=1
else
    echo "Sua máquina está configurada com o sistema Legacy"
    BOOT_LEGACY=1
fi

# Testa conexão com rede
echo "Testando conexão internet..."
ping -c 4 -q archlinux.org
if [ $? -eq 0 ]; then
    echo "Conexão ativa!"
else
    echo "Conexão inativa!"
    echo
    echo "Vamos tentar realizar uma conexão utilizando o camando dhcpcd? Sim!"
    echo
    ip link show
    echo
    echo "Selecione o número de sua interface Ethernet:"
    read num_interface
    interface_rede=$(ip link show | grep ""$num_interface":" | cut -d\: -f2 | tr -d " ")
    echo "Interface selecionada: "$interface_rede""
    dhcpcd "$interface_rede"
    ping -c 4 -q archlinux.org
    test $? -eq 0 && echo "Conexão ativa!" || echo "Conexão ainda inativa!"
fi

# Atualiza relógio do sistema
echo "Atualizando relógio..."
timedatectl set-ntp true

# Paticiona disco
cfdisk

# Formata partições
mkfs.ext4 /dev/sda1

# Montar sistema
mount /dev/sda1 /mnt

# Instala Arch
pacstrap /mnt base base-devel

genfstab /mnt >> /mnt/etc/fstab

cat /mnt/etc/fstab

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