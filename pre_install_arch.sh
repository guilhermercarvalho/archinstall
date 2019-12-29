
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
#                                  Tipo de Boot
#                                  ---- -- ----
#       $BOOT_EFI          Suporte para boot do tipo UEFI
#       $BOOT_LEGACY        Suporte para boot do tipo LEGACY
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
echo '-------------------------------------------------------------------------------'
echo '     ____               ____           __        ____   ___              __    '
echo '    / __ \________     /  _/___  _____/ /_____ _/ / /  /   |  __________/ /_   '
echo '   / /_/ / ___/ _ \    / // __ \/ ___/ __/ __ `/ / /  / /| | / ___/ ___/ __ \  '
echo '  / ____/ /  /  __/  _/ // / / (__  ) /_/ /_/ / / /  / ___ |/ /  / /__/ / / /  '
echo ' /_/   /_/   \___/  /___/_/ /_/____/\__/\__,_/_/_/  /_/  |_/_/   \___/_/ /_/   '
echo '                                                                               '
echo '                 Por Guilherme Carvalho - https://github.com/guilhermercarvalho'
echo '-------------------------------------------------------------------------------'
echo
#
#
#######################################################################################
#
#                                Messagem de Boas-Vindas
#                                -------- -- -----------
#
echo "####################################################################"
echo "#                                                                  #"
echo "# Bem-Vindo a Pré-Configuração Inicial de Instalação do Arch Linux #"
echo "#                                                                  #"
echo "####################################################################"
_fim_msg
#
#
#######################################################################################
# 
#                               Início Pré-Instalação
#                               ------ --------------
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

# Verifica conexão com internet
_ping_internet

# Conecta uma interface à uma rede
if [ $? -ne 0 ]; then
    _fim_msg
    echo 'Selecione um interface de rede:'
    ip -o link show | awk -F': ' '{print $2}'
    echo
    read -p "Interface selecionada: " interface_rede
    dhcpcd "${interface_rede}"
    unset interface_rede
    _fim_msg

    _ping_internet

    if [ $? -ne 0 ]; then
        _fim_msg
        printf "${red_full}" "FALHA NA CONECXÃO"
        printf "${red_full}" "SAINDO DO PROGRAMA..."
        exit -1
    fi
fi
_fim_msg

# Atualização do relógio do sistema
echo "#################################"
echo "# Relógio do sistema atualizado #"
echo "#################################"
_fim_msg
timedatectl set-ntp true

# Paticionamento de disco
echo "#############################################"
echo "#        Particionamento de Disco           #"
echo "#                                           #"
echo "# EFI disponível                            #"
echo "# /dev/sda1: EFI partição de boot - 260 MiB #"
echo "# /dev/sda2: Linux filesystem - +20 GiB     #"
echo "#                                           #"
echo "# LEGACY disponível                         #"
echo "# /dev/sda1: Linux filesystem - +10 GiB     #"
echo "#                                           #"
echo "#                            *recomendação  #"
echo "#############################################"
_fim_msg
cfdisk

# Lista partições criadas
fdisk -l
_fim_msg

# Configurações necessárias para sistemas efi e legacy
if [ ${BOOT_EFI} -eq 1 ]; then
    _efi_system
elif [ ${BOOT_LEGACY} -eq 1 ]; then
    _legacy_system
fi
_fim_msg

# Atualizando pacman e instalando reflector
echo "########################"
echo "# Instalando reflector #"
echo "########################"
pacman -S reflector --noconfirm
_fim_msg

echo "####################################"
echo "# Procurando por melhores espelhos #"
echo "####################################"
reflector --country Brazil --age 12 --protocol http --sort rate --save /etc/pacman.d/mirrorlist
yes no | pacman -Syyuu
_fim_msg

# Instalar Arch em disco
echo "#######################################"
echo "# Instalando arch em novo dispositivo #"
echo "#######################################"
pacstrap /mnt base base-devel linux linux-firmware nano vim bash-completion dhcpcd git
_fim_msg

# Gerendo arquivo fstab
echo "#########################"
echo "# Gerendo arquivo fstab #"
echo "#########################"
genfstab /mnt >> /mnt/etc/fstab
_fim_msg

# Exibindo arquivo fstab gerado
cat /mnt/etc/fstab
_fim_msg

# Fim da pré-instação
echo "#########################"
echo "# FIM DA PRÉ-INSTALAÇÃO #"
echo "#########################"
_fim_msg

echo "#################################"
echo "# Copiando archinstal para /mnt #"
echo "#################################"
cp -r ./archinstall /mnt

echo "#######################"
echo "# Comando arch-chroot #"
echo "#######################"
arch-chroot /mnt sh /archinstal/config_sys_arch.sh

exit 0