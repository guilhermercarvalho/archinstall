#!/usr/bin/env bash
#
# archinstall.sh - Instala e Configura o Arch Linux
#
# Site  : https://github.com/guilhermercarvalho/archinstall
# Autor : Guilherme Carvalho <guilhermercarvalho512@gmail.com>
#
# -------------------------------------------------------------------------------------
#
#  Este programa executa a instalação e a configuração do Arch Linux em seu sistema com
# interação mínima do usuário
#
# -------------------------------------------------------------------------------------
#
# Histórico:
#
#   v1.1 2020-1-24, Guilherme Carvalho:
#       - Refatoração de código
#       - Particionamento dinâmico
#       - Descrição detalhada
#       - Opções adicionadas
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
#       $IDIOMA_TECLADO     Keymap utilizado, padrão "br-abnt2".
#       $TIMEZONE           Configura fuso, padrão "Sao_Paulo".
#       $NOME_HOST          Nome da máquina.
#
# 
#                                  Tipo de Boot
#                                  ---- -- ----
#       $BOOT_EFI          Suporte para boot do tipo UEFI
#       $BOOT_LEGACY       Suporte para boot do tipo LEGACY
# 
# --------------------------------------------------------------------------------------
#
#                               Cores para exibição
#                               ----- ---- --------
#       red e red_full      vermelho    e   vermelho_completo
#       grn e grn_full      verde       e   verde_completo
#       yel e yel_full      amarelo     e   amarelo_completo
#       blu e blu_full      azul        e   azul_completo
#       mag e mag_full      magenta     e   magenta_completo
#       cyn e cyn_full      ciano       e   ciano_completo
#
#       end                 fim
#
# --------------------------------------------------------------------------------------
# Boot do sistema
BOOT_EFI=0
BOOT_LEGACY=0

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

# Dispositivo /dev/sdX
DEV=''

# Pacotes pacman
INSTALL_PKG="linux linux-api-headers linux-firmware intel-ucode util-linux nano ntfs-3g vim"
#
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

_tipo_boot() {
    printf "Tipo de boot do sistema: "
    if [ -d /sys/firmware/efi/efivars ]; then
        BOOT_EFI=1
        printf "${grn_full}" "UEFI\n"
    else
        BOOT_LEGACY=1
        printf "${yel_full}" "LEGACY\n"
    fi
}

_efi_system() {
    # Formatar partições
    read -p "/dev/sd${DEV}1: EFI System?[S/n]" resposta
    _ler_resposta
    if [ $? -eq 0 ]; then
        mkfs.fat -F32 /dev/sd${DEV}1
    fi

    read -p "/dev/sd${DEV}2: Linux filesystem?[S/n]" resposta
    _ler_resposta
    if [ $? -eq 0 ]; then
        mkfs.ext4 /dev/sd${DEV}2
    fi

    # Montar sistema
    echo "################################"
    echo "# Montando raíz do sistema EFI #"
    echo "################################"
    mount /dev/sd${DEV}2 /mnt
    mkdir -p /mnt/boot
    mount /dev/sd${DEV}1 /mnt/boot
}

_legacy_system() {
    # Formatar partições
    read -p "/dev/sd${DEV}1: Linux filesystem?[S/n]" resposta
    _ler_resposta
    if [ $? -eq 0 ]; then
        mkfs.ext4 /dev/sd${DEV}1
    fi

    # Montar sistema
    echo "###################################"
    echo "# Montando raíz do sistema LEGACY #"
    echo "###################################"
    mount /dev/sd${DEV}1 /mnt
}
#
#
#######################################################################################
#
#                                     Menssagem
#                                     ---------
#
echo '--------------------------------------------------------------------'
echo '    ___              __       ____           __        ____'
echo '   /   |  __________/ /_     /  _/___  _____/ /_____ _/ / /'
echo '  / /| | / ___/ ___/ __ \    / // __ \/ ___/ __/ __ `/ / / '
echo ' / ___ |/ /  / /__/ / / /  _/ // / / (__  ) /_/ /_/ / / /  '
echo '/_/  |_/_/   \___/_/ /_/  /___/_/ /_/____/\__/\__,_/_/_/   '
echo '                                                           '
echo '      Por Guilherme Carvalho - https://github.com/guilhermercarvalho'
echo '--------------------------------------------------------------------'
echo
#
#
#######################################################################################
#
#                                Messagem de Boas-Vindas
#                                -------- -- -----------
#
echo "########################################"
echo "#                                      #"
echo "# Bem-Vindo a Instalação do Arch Linux #"
echo "#                                      #"
echo "########################################"
echo
#
#
#######################################################################################
# 
#                               Início Pré-Instalação
#                               ------ --------------
#

# Verifica conexão com internet
_ping_internet

# Conecta uma interface à uma rede
if [ $? -ne 0 ]; then
    echo 'Selecione um interface de rede:'
    ip -o link show | awk -F': ' '{print $2}'
    echo
    read -p "Interface selecionada: " interface_rede
    dhcpcd "${interface_rede}"
    unset interface_rede

    _ping_internet

    if [ $? -ne 0 ]; then
        printf "${red_full}" "FALHA NA CONECXÃO"
        printf "${red_full}" "SAINDO DO PROGRAMA..."
        exit -1
    fi
fi

# Atualização do relógio do sistema
echo "Atualizando relógio do sistema"
timedatectl set-ntp true

# Define tipo de boot disponível (UEFI ou Legacy)
_tipo_boot

# Paticionamento de disco
echo "#############################################"
echo "#        Particionamento de Disco           #"
echo "#                                           #"
echo "# UEFI (gpt)                                #"
echo "# /dev/sdN1: EFI partição de boot - 260 MiB #"
echo "# /dev/sdN2: Linux filesystem - +20 GiB     #"
echo "#                                           #"
echo "# LEGACY (dos)                              #"
echo "# /dev/sdN1: Linux filesystem - +10 GiB     #"
echo "#                                           #"
echo "#                            *recomendação  #"
echo "#############################################"

# Lista partições disponíveis
fdisk -l
sleep 5

echo "Selecione o dispositivo sdX:"
read DEV

printf "\nIniciando fdisk para realização do paricionamento"
cfdisk /dev/sd${DEV}

# Lista partições criadas
fdisk -l
sleep 5

# Configurações necessárias para sistemas efi e legacy
if [ ${BOOT_EFI} -eq 1 ]; then
    _efi_system
elif [ ${BOOT_LEGACY} -eq 1 ]; then
    _legacy_system
fi

# Atualizando pacman e instalando reflector
echo "Instalando reflector"
pacman -S reflector --noconfirm

echo "Encontrando espelhos do pacman mais recentes no Brasil"
reflector --country Brazil --age 12 --protocol http --sort rate --save /etc/pacman.d/mirrorlist
yes no | pacman -Syyuu

echo "Instalando arch em novo dispositivo"
pacstrap /mnt base base-devel ${INSTALL_PKG}

echo "Gerendo arquivo fstab"
genfstab /mnt >> /mnt/etc/fstab

# Exibindo arquivo fstab gerado
cat /mnt/etc/fstab

echo "Copiando archinstall para /mnt"
cp -vr ./archinstall/ /mnt

echo "Entrando em modo arch-chroot e iniciando Config Sys Arch..."
arch-chroot /mnt sh /archinstall/config_sys_arch.sh

exit 0
